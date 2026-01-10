class FindFriend {
  final int id;
  final String nickname;
  final String avatarUrl;
  String friendshipStatus;

  FindFriend({
    required this.id,
    required this.nickname, 
    required this.avatarUrl,
    required this.friendshipStatus, 
  });

  factory FindFriend.fromJson(Map<String, dynamic> json) {
    return FindFriend(
      id: json['id'] ?? -1313423322,
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      friendshipStatus: json['status'] ?? 'None',
    );
  }
}