import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/blocs/player_event.dart';
import 'package:mafia_classic/blocs/player_state.dart';
import 'package:mafia_classic/repositories/player_repository.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerRepository playerRepository;

  PlayerBloc({required this.playerRepository}) : super(PlayerInitial()) {
    on<LoadPlayers>((event, emit) async {
      try {
        final players = playerRepository.getPlayers();
        emit(PlayerLoadSuccess(players));
      } catch (e) {
        emit(PlayerLoadFailure(e));
      }
    });
    on<AddPlayer>((event, emit) async {
      playerRepository.addPlayer(event.player);
      final players = playerRepository.getPlayers();
      emit(PlayerLoadSuccess(players));
    });
    on<SendRequest>((event, emit) async {
      playerRepository.sendRequest(event.playerIdFrom, event.playerIdTo);
      final players = playerRepository.getPlayers();
      emit(PlayerLoadSuccess(players));
    });
    on<AcceptRequest>((event, emit) async {
      playerRepository.acceptRequst(event.playerId, event.acceptedFriendId);
      final friends = playerRepository.getFriendList(event.playerId);
      emit(PlayerFriendsLoadSuccess(friends));
    });
    on<DeleteFriend>((event, emit) async {
      playerRepository.deleteFriend(event.playerId, event.deleteFriendId);
      final friends = playerRepository.getFriendList(event.playerId);
      emit(PlayerFriendsLoadSuccess(friends));
    });
    on<GetFriendsList>((event, emit) async {
      try {
        final friends = playerRepository.getFriendList(event.playerId);
        emit(PlayerFriendsLoadSuccess(friends));
      } catch (e) {
        emit(PlayerFriendsLoadFailure(e));
      }      
    });
    on<GetRequestsList>((event, emit) async {
      final requests = playerRepository.getRequestsList(event.playerId);
      emit(PlayerRequestsLoadSuccess(requests));
    });
  }
}