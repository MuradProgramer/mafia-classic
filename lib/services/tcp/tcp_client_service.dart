import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  final StreamController<String> _controller = StreamController<String>.broadcast();
  Stream<String> get messages => _controller.stream;

  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(true);

  bool get isConnected => _socket != null;

  Future<void> connect(String host, int port, User user) async {
    // var connectivityResult = await Connectivity().checkConnectivity();

    // if (connectivityResult.contains(ConnectivityResult.none)) {
    //   log("🚫 No physical internet. Reconnection aborted - TCP CLIENT SERVICE");
    //   connectionStatus.value = false;
    //   return;
    // }

    // if (_socket != null) return;
    
    // try {
    //   _socket = await SecureSocket.connect(
    //     host, 
    //     port,
    //     onBadCertificate: (X509Certificate cert) => true,
    //     timeout: const Duration(seconds: 5),
    //   );
      
      // _socket!.listen(
      //   _onData, 
      //   onError: (e) {
      //     log('⚠️ Socket error: $e');
      //     _handleDisconnect();
      //   }, 
      //   onDone: () {
      //     log('❌ Connection closed');
      //     _handleDisconnect();
      //   }
      // );
      
    //   connectionStatus.value = true;
    //   sendMessage(ClientCommand.authorize.value, user.accessToken);
      
      // _keepAliveTimer?.cancel();
      // _keepAliveTimer =Timer.periodic(const Duration(seconds: 30), (t) {
      //   if (_socket != null) {
      //     sendMessage(ClientCommand.ping.value, "");
      //   }
      // });
    // } catch (e) {
    //   _handleDisconnect();
    // }

    if (_socket != null) return;

    log("[TCP] Starting connection sequence...");

    // Try 3 times with a 2-second delay between attempts
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        // Check physical hardware
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult.contains(ConnectivityResult.none)) {
          log("⏳ Attempt $attempt: No WiFi/Data hardware active.");
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        log("🔌 Attempt $attempt: Connecting to $host:$port...");
        
        // Use a slightly longer timeout for the initial handshake
        _socket = await SecureSocket.connect(
          host, 
          port,
          onBadCertificate: (_) => true,
          timeout: const Duration(seconds: 7), 
        );

        // --- SUCCESS ---
        log("✅ Connected successfully on attempt $attempt");
        
        _socket!.listen(
          _onData, 
          onError: (e) => _handleDisconnect(), 
          onDone: () => _handleDisconnect(),
          cancelOnError: true,
        );

        connectionStatus.value = true;
        sendMessage(ClientCommand.authorize.value, user.accessToken);
        
        _keepAliveTimer?.cancel();
        _keepAliveTimer =Timer.periodic(const Duration(seconds: 30), (t) {
          if (_socket != null) {
            sendMessage(ClientCommand.ping.value, "");
          }
        });
        
        return; // Exit the function entirely on success

      } catch (e) {
        log("❌ Attempt $attempt failed: $e");
        _socket?.destroy(); // Ensure the partial socket is killed
        _socket = null;
        
        if (attempt < 3) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    // If we reach here, all attempts failed
    _handleDisconnect();
  }

  final List<int> _buffer = [];

  void _onData(List<int> data) {
    _buffer.addAll(data);

    while (true) {
      if (_buffer.length < 8) return;

      final headerBytes = _buffer.sublist(0, 8);
      final header = ByteData.sublistView(Uint8List.fromList(headerBytes));

      final messageTypeId = header.getInt32(0, Endian.big);
      final payloadLength = header.getInt32(4, Endian.big);

      if (_buffer.length < 8 + payloadLength) return;

      final payloadBytes = _buffer.sublist(8, 8 + payloadLength);
      final payload = utf8.decode(payloadBytes);

      if (!(messageTypeId == ServerEvent.gameTimerUpdate.value || messageTypeId == ServerEvent.roomTimerUpdate.value)) {
        log('📩 ON MESSAGE  |  MessageType: $messageTypeId  |  Payload: $payload');
      }

      _buffer.removeRange(0, 8 + payloadLength);

      _onMessage(messageTypeId, payload);
    }
  }

  void _onMessage(int typeId, String payload) {
    
    ServerEvent eventType = ServerEventExtension.fromValue(typeId) ?? ServerEvent.errorEvent;

    // if (!(eventType == ServerEvent.gameTimerUpdate || eventType == ServerEvent.roomTimerUpdate)) {
    //   print('Type ID: $typeId');
    //   log('----------- ON MESSAGE HANDLER ----------');
    //   log('🔔 Это приветственное сообщение: \n$payload');
    //   log('----------------------------------------');
    // }

    EventRouterService().dispatch(eventType, payload);
  }

  void sendMessage(int messageTypeId, String payload) {
    if (_socket == null) {
      connectionStatus.value = false;
      return;
    }
    
    final payloadBytes = utf8.encode(payload);
    final length = payloadBytes.length;

    final buffer = BytesBuilder();
    final header = ByteData(8);
    header.setInt32(0, messageTypeId, Endian.big);
    header.setInt32(4, length, Endian.big);

    buffer.add(header.buffer.asUint8List());
    buffer.add(payloadBytes);

    _socket!.add(buffer.toBytes());
    log('📤 SEND METHOD | Sent type=$messageTypeId, len=$length, payload="$payload"');
  }
  
  void _handleDisconnect() {
    _socket?.destroy();
    _socket = null;
    _keepAliveTimer?.cancel();
    connectionStatus.value = false;
  }

  void disconnect() {
    _handleDisconnect();
  }

  void dispose() {
    _handleDisconnect();
    _controller.close();
    GeneralCacheService().clearAllData();
  }
}
