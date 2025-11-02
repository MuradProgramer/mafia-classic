import 'dart:async';
import 'dart:developer';
import 'package:mafia_classic/services/tcp/enums.dart';

class EventRouterService {
  static final EventRouterService _instance = EventRouterService._internal();
  factory EventRouterService() => _instance;
  EventRouterService._internal();

  final Map<ServerEvent, StreamController<String>> _streams = {};

  Stream<String> subscribe(ServerEvent eventType) {
    _streams.putIfAbsent(eventType, () => StreamController.broadcast());
    return _streams[eventType]!.stream;
  }

  // GLOBAL: одно место, куда летит всё (для “показывать везде”)
  final _global = StreamController<MapEntry<ServerEvent, String>>.broadcast();

  /// Глобальный поток — слушаем в корневом виджете приложения (или Shell)
  Stream<MapEntry<ServerEvent, String>> get globalStream => _global.stream;

  void dispatch(ServerEvent eventType, String payload) {
    print(eventType);
    if (_streams.containsKey(eventType)) {
      _streams[eventType]!.add(payload);
    } else {
      log('⚠️ No listeners for $eventType');
    }

    // global
    if (!_global.isClosed) {
      _global.add(MapEntry(eventType, payload));
    }
  }

  Future<void> dispose() async {
    for (final c in _streams.values) {
      await c.close();
    }
    await _global.close();
  }
}
