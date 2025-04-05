class InGameMessage {
  final String? nickname;
  final String content;
  String? avatarUrl;
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

class PlayersFromAfk {
  final String nickname;
  bool isAlive;
  String? role;
  String? avatarUrl;
  bool? isMarked;

  PlayersFromAfk({
    required this.nickname, 
    required this.isAlive, 
    required this.role,
    required this.avatarUrl,
    required this.isMarked
  });

  factory PlayersFromAfk.fromJson(Map<String, dynamic> json) {

    return PlayersFromAfk(
      nickname: json['nickname'],
      isAlive: json['isAlive'],    
      role: json['role'],    
      avatarUrl: json['avatarUrl'], 
      isMarked: json['isMarked'],
    );
  }
}