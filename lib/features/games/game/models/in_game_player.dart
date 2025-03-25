class InGamePlayer {
  final String nickname;
  bool isAlive;
  bool isRevealed;
  String? role;
  String? avatarUrl;
  List<String>? votesOfPlayer;

  InGamePlayer({
    required this.nickname, 
    required this.isAlive, 
    required this.isRevealed,
    this.role,
    this.avatarUrl,
    this.votesOfPlayer
  });
}