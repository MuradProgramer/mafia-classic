import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';

class TcpClientService {
  static final TcpClientService _instance = TcpClientService._internal();
  factory TcpClientService() => _instance;
  TcpClientService._internal();

  Timer? _keepAliveTimer;
  SecureSocket? _socket;

  String? _lastHost;
  int? _lastPort;
  User? _lastUser;

  bool _isConnecting = false;

  // Prevents _handleDisconnect() from setting connectionStatus=false
  // more than once per connection cycle. Without this, multiple callers
  // (onDone, onError, notifyNetworkLost, flush error) all race to set
  // false→false, which ValueNotifier silently suppresses — so on the
  // 2nd+ drop the overlay never appears.
  bool _isDisconnected = true;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  Stream<String> get messages => _controller.stream;

  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);

  bool get isConnected => _socket != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> connect(String host, int port, User user) async {
    if (_isConnecting) {
      log('[TCP] connect() blocked — already connecting');
      return;
    }

    if (_socket != null) {
      log('[TCP] connect() — destroying stale socket before reconnect');
      _socket?.destroy();
      _socket = null;
    }

    _lastHost = host;
    _lastPort = port;
    _lastUser = user;

    await _connectInternal(host, port, user);
  }

  void sendMessage(int messageTypeId, String payload) {
    print(_socket.toString());
    if (_socket == null) {
      log('[TCP] sendMessage: socket is null — skipping');
      return;
    }
    try {
      final payloadBytes = utf8.encode(payload);
      final length = payloadBytes.length;

      final buffer = BytesBuilder();
      final header = ByteData(8);
      header.setInt32(0, messageTypeId, Endian.big);
      header.setInt32(4, length, Endian.big);

      buffer.add(header.buffer.asUint8List());
      buffer.add(payloadBytes);

      _socket!.add(buffer.toBytes());
      _socket!.flush().catchError((e) {
        log('[TCP] 🚨 Flush failed — network likely dead: $e');
        _handleDisconnect();
      });
      log('📤 SEND | type=$messageTypeId len=$length payload="$payload"');
    } catch (e) {
      log('[TCP] ⚠️ sendMessage threw: $e');
      _handleDisconnect();
    }
  }

  /// Called by GameWrapper when the OS reports network loss.
  /// Immediately drives the disconnect so the overlay appears right away —
  /// we cannot rely on socket onDone because Android does NOT fire onDone
  /// when the network drops abruptly. The _isDisconnected guard inside
  /// _handleDisconnect() ensures it's a no-op if onDone happens to fire later.
  void notifyNetworkLost() {
    log('[TCP] notifyNetworkLost() — forcing disconnect immediately');
    _handleDisconnect();
  }

  /// Hard disconnect — for logout / app dispose only.
  void disconnect() {
    log('[TCP] disconnect() — hard close');
    _handleDisconnect();
  }

  void dispose() {
    _handleDisconnect();
    _controller.close();
    GeneralCacheService().clearAllData();
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _connectInternal(String host, int port, User user) async {
    log('[TCP] _connectInternal │ socket=${_socket != null ? "EXISTS" : "null"} │ _isConnecting=$_isConnecting');

    if (_socket != null) {
      log('[TCP] SKIPPED — socket already open');
      return;
    }
    if (_isConnecting) {
      log('[TCP] SKIPPED — already connecting');
      return;
    }

    _isConnecting = true;

    // Give Android network stack time to fully associate after the
    // connectivity stream fires — without this the first SecureSocket.connect
    // fails even though WiFi shows as connected.
    await Future.delayed(const Duration(milliseconds: 500));

    for (int attempt = 1; attempt <= 3; attempt++) {
      log('[TCP] ── Attempt $attempt/3 → $host:$port');
      try {
        _socket = await SecureSocket.connect(
          host,
          port,
          onBadCertificate: (cert) {
            log('[TCP] Bad cert from ${cert.subject} — accepting');
            return true;
          },
          timeout: const Duration(seconds: 3),
        );

        log('[TCP] ✅ Connected on attempt $attempt');

        _socket!.listen(
          _onData,
          onError: (e) {
            log('[TCP] ⚠️ Socket error: $e');
            _handleDisconnect();
          },
          onDone: () {
            // May or may not fire on Android network drops.
            // _isDisconnected guard makes this a safe no-op if
            // notifyNetworkLost() already ran first.
            log('[TCP] Socket onDone');
            //_handleDisconnect();
          },
          cancelOnError: true,
        );

        // Reset the guard NOW — we have a live connection.
        _isDisconnected = false;
        connectionStatus.value = true;
        log('[TCP] connectionStatus → true');

        sendMessage(ClientCommand.authorize.value, user.accessToken);

        _keepAliveTimer?.cancel();
        _keepAliveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          if (_socket != null) {
            try {
              sendMessage(ClientCommand.ping.value, '');
            } catch (e) {
              log('[TCP] Ping failed — forcing disconnect');
              _handleDisconnect();
            }
          }
        });

        _isConnecting = false;
        return;

      } on HandshakeException catch (e) {
        log('[TCP] ❌ HandshakeException (TLS — backend issue): $e');
        _socket?.destroy();
        _socket = null;
        break;

      } on SocketException catch (e) {
        log('[TCP] ❌ Attempt $attempt SocketException: ${e.message} osError=${e.osError}');
        _socket?.destroy();
        _socket = null;
        if (attempt < 3) await Future.delayed(const Duration(seconds: 2));

      } on TimeoutException catch (_) {
        log('[TCP] ❌ Attempt $attempt timed out (7s)');
        _socket?.destroy();
        _socket = null;
        if (attempt < 3) await Future.delayed(const Duration(seconds: 2));

      } catch (e, stack) {
        log('[TCP] ❌ Attempt $attempt unexpected: $e\n$stack');
        _socket?.destroy();
        _socket = null;
        if (attempt < 3) await Future.delayed(const Duration(seconds: 2));
      }
    }

    log('[TCP] 💥 All 3 attempts failed');
    _isConnecting = false;
    _handleDisconnect();
  }

  // ─── Data parsing ─────────────────────────────────────────────────────────

  final List<int> _buffer = [];

  void _onData(List<int> data) {
    try {
      _buffer.addAll(data);
      while (true) {
        if (_buffer.length < 8) return;

        final header = ByteData.sublistView(
          Uint8List.fromList(_buffer.sublist(0, 8)),
        );
        final messageTypeId = header.getInt32(0, Endian.big);
        final payloadLength = header.getInt32(4, Endian.big);

        if (payloadLength < 0 || payloadLength > 10 * 1024 * 1024) {
          log('[TCP] ⚠️ Invalid payloadLength=$payloadLength — clearing buffer');
          _buffer.clear();
          return;
        }

        if (_buffer.length < 8 + payloadLength) return;

        final payload = utf8.decode(
          _buffer.sublist(8, 8 + payloadLength),
          allowMalformed: true,
        );

        if (!(messageTypeId == ServerEvent.gameTimerUpdate.value ||
            messageTypeId == ServerEvent.roomTimerUpdate.value)) {
          log('📩 MSG | type=$messageTypeId payload=$payload');
        }

        _buffer.removeRange(0, 8 + payloadLength);
        _onMessage(messageTypeId, payload);
      }
    } catch (e, stack) {
      log('[TCP] ⚠️ _onData error: $e\n$stack');
      _buffer.clear();
      _handleDisconnect();
    }
  }

  void _onMessage(int typeId, String payload) {
    final eventType =
        ServerEventExtension.fromValue(typeId) ?? ServerEvent.errorEvent;
    EventRouterService().dispatch(eventType, payload);
  }

  // ─── Cleanup ──────────────────────────────────────────────────────────────

  void _handleDisconnect() {
    // Guard: only run once per connection cycle.
    // Multiple callers (onDone, onError, notifyNetworkLost, flush error)
    // can all call this. Only the first call matters — it does the
    // true→false transition that ValueNotifier will notify listeners for.
    // All subsequent calls are no-ops because false→false is suppressed.
    if (_isDisconnected) {
      log('[TCP] _handleDisconnect() — already disconnected, skipping');
      return;
    }

    log('[TCP] _handleDisconnect() — cleaning up, connectionStatus → false');
    _isDisconnected = true;
    _socket?.destroy();
    _socket = null;
    _keepAliveTimer?.cancel();
    _isConnecting = false;
    connectionStatus.value = false;
  }
}