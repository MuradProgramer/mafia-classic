import 'dart:async';
import 'dart:ffi';

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

class LoadFriendsEvent {}

class NewFriendAddedEvent {
  final Friendship requestData;
  NewFriendAddedEvent(this.requestData);
}

class DeleteFriendEvent {
  final int friendId;
  DeleteFriendEvent(this.friendId);
}

class CancelFriendRequest {
  final int playerId;
  CancelFriendRequest(this.playerId);
}

class FriendOnlineEvent {
  final int friendId;
  FriendOnlineEvent(this.friendId);
}

class FriendOfflineEvent {
  final int friendId;
  FriendOfflineEvent(this.friendId);
}

class FriendNewMessageEvent {
  final Message message;
  final int friendId;
  FriendNewMessageEvent(this.message, this.friendId);
}

class FriendMessagesReadedEvent {
  final int friendId;
  FriendMessagesReadedEvent({required this.friendId});
}

class FriendRequestSentEvent {
  final int friendId;
  FriendRequestSentEvent(this.friendId);
}

class FriendRequestDeclinedEvent {
  final int playerId;
  FriendRequestDeclinedEvent(this.playerId);
}

class FriendJoinedRoomEvent {
  final int friendId;
  final String gameTitle;
  FriendJoinedRoomEvent(this.friendId, this.gameTitle);
}

class FriendLeftRoomEvent {
  final int friendId;
  FriendLeftRoomEvent(this.friendId);
}

// class FriendUnreadMessagesEvent {
//   final int id;
//   final int unreadCount;
//   FriendUnreadMessagesEvent(this.id, this.unreadCount);
// }