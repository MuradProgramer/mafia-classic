import 'dart:async';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;

  EventBus._internal();

  final _controller = StreamController<dynamic>.broadcast();

  Stream<T> on<T>() => _controller.stream.where((event) => event is T).cast<T>();

  void emit(event) => _controller.add(event);
}
