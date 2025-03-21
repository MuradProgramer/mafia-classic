class InGamePlayer {
  final String nickname;
  final String role;
  bool isAlive;
  bool isRevealed;

  InGamePlayer({
    required this.nickname, 
    required this.role, 
    required this.isAlive, 
    required this.isRevealed
  });
}