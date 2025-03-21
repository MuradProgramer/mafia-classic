class InterviewedPlayer {
  final String firstPlayer;
  final String secondPlayer;
  final String message;

  InterviewedPlayer({
    required this.firstPlayer, 
    required this.secondPlayer,
    required this.message
  });

  factory InterviewedPlayer.fromJson(Map<String, dynamic> json) {
    return InterviewedPlayer(
      firstPlayer: json['firstPlayer'],
      secondPlayer: json['secondPlayer'],
      message: json['message']
    );
  }
}