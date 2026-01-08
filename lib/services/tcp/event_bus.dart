import 'dart:async';

import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';


class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  //? A generic stream controller that broadcasts EVERYTHING
  final _controller = StreamController<dynamic>.broadcast();

  //? Method to fire an event
  void fire(dynamic event) {
    _controller.add(event);
  }

  //? Method to listen for specific types of events
  Stream<T> on<T>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }
}

class FriendRequestReceivedEvent {
  final Map<String, dynamic> requestData;
  FriendRequestReceivedEvent(this.requestData);
}

class NewFriendAddedEvent {
  final Friendship requestData;
  NewFriendAddedEvent(this.requestData);
}

class DeleteFriendEvent {
  final String friendId;
  DeleteFriendEvent(this.friendId);
}

class FriendOnlineEvent {
  final String friendNickname;
  FriendOnlineEvent(this.friendNickname);
}

class FriendOfflineEvent {
  final String friendNickname;
  FriendOfflineEvent(this.friendNickname);
}

class FriendNewMessageEvent {
  final Message message;
  FriendNewMessageEvent(this.message);
}