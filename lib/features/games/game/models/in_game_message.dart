class InGameMessage {
  final String nickname;
  final String content;
  String avatarUrl;
  String type;

  InGameMessage({
    required this.nickname,
    required this.content,
    required this.avatarUrl,
    this.type = 'Default',
  });

  factory InGameMessage.fromJson(Map<String, dynamic> json) {
    return InGameMessage(
      nickname: json['nickname'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      avatarUrl: ''
    );
  }
}