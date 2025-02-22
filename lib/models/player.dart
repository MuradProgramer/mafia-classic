abstract class _Player {
  final int id;
  final String username;
  final String profileImage;

  _Player({
    required this.id, 
    required this.username, 
    required this.profileImage
  });
}

class Player extends _Player {
  final int experience;
  final int gamesPlayed;
  final int gamesWon;

  Player({
    required super.id,
    required super.username,
    required super.profileImage,
    required this.experience,
    required this.gamesPlayed,
    required this.gamesWon,
  });
}

class PlayerFull extends _Player {
  final bool isOnline;
  final DateTime lastSeenTime;
  final int experience;
  final int gamesWon;
  final int gamesPlayed;
  final List<int> friendsID;
  final List<int> requestsID;

  PlayerFull({
    required super.id, 
    required super.username,
    required super.profileImage,
    required this.isOnline, 
    required this.lastSeenTime, 
    required this.experience,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.friendsID, 
    required this.requestsID,
  });
}

class Friend extends _Player{
  final bool isOnline;
  final DateTime lastSeen;

  Friend({
    required super.id, 
    required super.username, 
    required super.profileImage,
    required this.isOnline,
    required this.lastSeen
  });  
}

class LobbyPlayer {
  final String nickname;
  final String avatarUrl;
  final bool isAlive;

  LobbyPlayer({
    required this.nickname, 
    required this.avatarUrl, 
    required this.isAlive
  });

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      isAlive: json['isAlive'] as bool
    );
  }
}