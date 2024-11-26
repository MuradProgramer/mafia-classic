import 'package:equatable/equatable.dart';
import 'package:mafia_classic/models/models.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();

  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoadInProgress extends PlayerState {}

class PlayerLoadSuccess extends PlayerState {
  final List<PlayerFull> players;

  const PlayerLoadSuccess(this.players);

  @override
  List<Object> get props => [players];
}

class PlayerFriendsLoadSuccess extends PlayerState {
  final List<Friend> friends;

  const PlayerFriendsLoadSuccess(this.friends);

  @override
  List<Object> get props => [friends];
}

class PlayerRequestsLoadSuccess extends PlayerState {
  final List<PlayerFull> requests;

  const PlayerRequestsLoadSuccess(this.requests);

  @override
  List<Object> get props => [requests];
}

////// FAILURE //////

class PlayerLoadFailure extends PlayerState {
  final Object? exception;

  const PlayerLoadFailure(this.exception);
}

class PlayerFriendsLoadFailure extends PlayerState {
  final Object? exception;

  const PlayerFriendsLoadFailure(this.exception);
}