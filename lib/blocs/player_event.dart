import 'package:equatable/equatable.dart';
import 'package:mafia_classic/models/models.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class LoadPlayers extends PlayerEvent {}

class AddPlayer extends PlayerEvent {
  final PlayerFull player;

  const AddPlayer(this.player);

  @override
  List<Object> get props => [ player ];
}

class SendRequest extends PlayerEvent {
  final int playerIdFrom;
  final int playerIdTo;

  const SendRequest(this.playerIdFrom, this.playerIdTo);

  @override
  List<Object> get props => [ playerIdFrom, playerIdTo ];
}

class AcceptRequest extends PlayerEvent {
  final int playerId;
  final int acceptedFriendId;

  const AcceptRequest({required this.playerId, required this.acceptedFriendId});

  @override
  List<Object> get props => [ playerId, acceptedFriendId ];
}

class DeleteFriend extends PlayerEvent {
  final int playerId;
  final int deleteFriendId;

  const DeleteFriend({required this.playerId, required this.deleteFriendId});

  @override
  List<Object> get props => [ playerId, deleteFriendId ];
}

class GetFriendsList extends PlayerEvent {
  final int playerId;

  const GetFriendsList({required this.playerId});

  @override
  List<Object> get props => [ playerId ];
}

class GetRequestsList extends PlayerEvent {
  final int playerId;

  const GetRequestsList({required this.playerId});

  @override
  List<Object> get props => [ playerId ];
}