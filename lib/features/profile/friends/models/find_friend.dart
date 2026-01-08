class FindFriend {
  final String nickname;
  final String avatarUrl;
  String friendshipStatus;

  FindFriend({
    required this.nickname, 
    required this.avatarUrl,
    required this.friendshipStatus, 
  });

  factory FindFriend.fromJson(Map<String, dynamic> json) {
    return FindFriend(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      friendshipStatus: json['status'] ?? 'None',
    );
  }
}