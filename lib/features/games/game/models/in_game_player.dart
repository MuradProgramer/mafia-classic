class InGamePlayer {
  final String nickname;
  bool isAlive;
  bool isRevealed;
  String? role;
  String? avatarUrl;

  InGamePlayer({
    required this.nickname, 
    required this.isAlive, 
    required this.isRevealed,
    this.role,
    this.avatarUrl
  });
}