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