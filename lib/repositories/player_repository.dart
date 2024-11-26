import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/repositories/abstract_player_repository.dart';

class PlayerRepository implements AbstractPlayerRepository {
  final List<PlayerFull> _players = [
    PlayerFull(
      id: 1, 
      username: 'musayev', 
      profileImage: 'assets/avatar.jpg', 
      isOnline: true, 
      lastSeenTime: DateTime(2024, 7, 20, 20, 18), 
      experience: 1500, 
      gamesPlayed: 62, 
      gamesWon: 35, 
      friendsID: [ 3, 4 ],
      requestsID: [2]
    ),
    PlayerFull(
      id: 2, 
      username: 'parvin', 
      profileImage: 'assets/avatar.jpg', 
      isOnline: false, 
      lastSeenTime: DateTime(2024, 7, 18, 14, 32), 
      experience: 1200, 
      gamesPlayed: 62, 
      gamesWon: 35, 
      friendsID: [ 3 ],
      requestsID: []
    ),
    PlayerFull(
      id: 3, 
      username: 'ramazan', 
      profileImage: 'assets/avatar.jpg', 
      isOnline: true, 
      lastSeenTime: DateTime(2024, 7, 21, 16, 45), 
      experience: 1300, 
      gamesPlayed: 62, 
      gamesWon: 35, 
      friendsID: [ 1, 2, 4 ],
      requestsID: []
    ),
    PlayerFull(
      id: 4, 
      username: 'vuqar', 
      profileImage: 'assets/avatar.jpg', 
      isOnline: false, 
      lastSeenTime: DateTime(2024, 7, 22, 12, 12), 
      experience: 900, 
      gamesPlayed: 62, 
      gamesWon: 35, 
      friendsID: [ 1, 3 ],
      requestsID: []
    ),
  ];

  @override
  List<PlayerFull> getPlayers() {
    return _players;
  }

  @override
  List<Friend> getFriendList(int playerId) {
    List<int> friendIds = _players.firstWhere((player) => player.id == playerId).friendsID;
    List<Friend> friendList = [];
    for (var player in _players) {
      if (friendIds.any((element) => element == player.id)) {
        friendList.add(Friend(
          id: player.id, 
          username: player.username,
          profileImage: player.profileImage,
          isOnline: player.isOnline,
          lastSeen: player.lastSeenTime
        ));
      }
    }
    return friendList;
  }

  @override
  List<PlayerFull> getRequestsList(int playerId) {
    List<int> requestIds = _players.firstWhere((player) => player.id == playerId).requestsID;
    List<PlayerFull> requestsList = [];
    for (var player in _players) {
      if (requestIds.any((element) => element == player.id)) {
        requestsList.add(player);
      }
    }
    return requestsList;
  }

  @override
  void addPlayer(PlayerFull player) {
    _players.add(player);
  }

  @override
  void sendRequest(int playerIdFrom, int playerIdTo) {
    _players.firstWhere((player) => player.id == playerIdTo).requestsID.add(playerIdFrom);
  }

  @override
  void acceptRequst(int playerId, int acceptedFriendId) {
    _players.firstWhere((player) => player.id == playerId).friendsID.add(acceptedFriendId);
    _players.firstWhere((player) => player.id == acceptedFriendId).friendsID.add(playerId);
  }

  @override
  void deleteFriend(int playerId, deleteFriendId) {
    _players.firstWhere((player) => player.id == playerId).friendsID
      .removeWhere((id) => id == deleteFriendId);
  }
}