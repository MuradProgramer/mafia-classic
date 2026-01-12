class InGamePlayer {
  final int id;
  final String nickname;
  bool isAlive;
  bool isRevealed;
  String? role;
  String? avatarUrl;
  List<int>? votesOfPlayer;

  InGamePlayer({
    required this.id,
    required this.nickname, 
    required this.isAlive, 
    required this.isRevealed,
    this.role,
    this.avatarUrl,
    this.votesOfPlayer
  });
}