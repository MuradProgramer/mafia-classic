import 'dart:ui';

class InGameMessage {
  final String? nickname;
  final String content;
  String? avatarUrl;
  String type;
  final bool colorHasOpacity;
  final Color color;
  

  InGameMessage({
    required this.nickname,
    required this.content,
    required this.avatarUrl,
    required this.colorHasOpacity,
    this.type = 'Default',
    this.color = const Color(0xFFFFB000)
  });

  factory InGameMessage.fromJson(Map<String, dynamic> json) {
    return InGameMessage(
      nickname: json['nickname'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      avatarUrl: '',
      colorHasOpacity: false
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