class InGameMessage {
  final String nickname;
  final String content;
  final String avatarUrl;
  final bool isSystemMessage;

  InGameMessage({
    required this.nickname,
    required this.content,
    required this.avatarUrl,
    this.isSystemMessage = false,
  });
}