import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';

class TcpClientService {
  static final TcpClientService _instance = TcpClientService._internal();
  factory TcpClientService() => _instance;
  TcpClientService._internal();

  SecureSocket? _socket;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get messages => _controller.stream;

  Future<void> connect(String host, int port, User user) async {
    log('[TCP] Connecting to $host:$port...');
    _socket = await SecureSocket.connect(
      host, 
      port,
      onBadCertificate: (X509Certificate cert) => true,
    );
    log('[TCP] Connected to $host:$port');
     _socket!.listen(_onData, onError: (e) {
      log('⚠️ Socket error: $e');
      disconnect();
    }, onDone: () {
      log('❌ Connection closed');
      disconnect();
    });

    sendMessage(ClientCommand.authorize.value, user.accessToken);
    //sendMessage(10000, "");

    Timer.periodic(const Duration(seconds: 30), (t) {
      sendMessage(ClientCommand.ping.value, "");
    });
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

    if (!(eventType == ServerEvent.gameTimerUpdate || eventType == ServerEvent.roomTimerUpdate)) {
      print('Type ID: $typeId');
      log('----------- ON MESSAGE HANDLER ----------');
      log('🔔 Это приветственное сообщение: \n$payload');
      log('----------------------------------------');
    }

    EventRouterService().dispatch(eventType, payload);
  }

  void sendMessage(int messageTypeId, String payload) {
    if (_socket == null) return;

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

  void disconnect() {
    _socket?.destroy();
    _socket = null;
    _controller.close();
    GeneralCacheService().clearAllData();
  }
}
