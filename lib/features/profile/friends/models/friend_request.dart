class FriendRequest {
  final int id;
  final String nickname;
  final String avatarUrl;

  FriendRequest({
    required this.id,
    required this.nickname,
    required this.avatarUrl
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? -1313423319,
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],   
    );
  }
}