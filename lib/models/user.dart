class User {
  final String email;
  final String nickname;
  final String avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;

  User({
    required this.email,
    required this.nickname,
    required this.avatarUrl,
    required this.accessToken, 
    required this.refreshToken, 
    required this.expirationDate,
  });
}

class Friendship {
  final String nickname;
  final String avatarUrl;
  final bool isOnline;
  final DateTime lastSeen;

  Friendship({
    required this.nickname, 
    required this.avatarUrl, 
    required this.isOnline, 
    required this.lastSeen
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'],    
      lastSeen: DateTime.parse(json['lastSeen']),    
    );
  }
}

class FindFriend {
  final String nickname;
  final String avatarUrl;
  final String friendshipStatus;
  final DateTime createdDateTime;

  FindFriend({
    required this.nickname, 
    required this.avatarUrl,
    required this.friendshipStatus, 
    required this.createdDateTime
  });

  factory FindFriend.fromJson(Map<String, dynamic> json) {
    return FindFriend(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      friendshipStatus: json['friendshipStatus'],    
      createdDateTime: DateTime.parse(json['createdDateTime']) ,    
    );
  }
}

class FriendRequest {
  final String nickname;
  final String avatarUrl;

  FriendRequest({
    required this.nickname, 
    required this.avatarUrl
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],   
    );
  }
}