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

  void dispatch(ServerEvent eventType, String payload) {
    print(eventType);
    if (_streams.containsKey(eventType)) {
      _streams[eventType]!.add(payload);
    } else {
      log('⚠️ No listeners for $eventType');
    }
  }
}
