import 'package:intl/intl.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';

class Friendship implements JsonModel {
  final String nickname;
  final String avatarUrl;
  bool isOnline;
  String gameTitle;
  DateTime lastSeen;

  static final DateFormat _customFormat = DateFormat('dd.MM.yyyy HH:mm');

  Friendship({
    required this.nickname, 
    required this.avatarUrl, 
    required this.isOnline, 
    required this.gameTitle,
    required this.lastSeen,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    final String lastSeenString = json['lastSeen'] as String? ?? '';
    
    DateTime parsedLastSeen = DateTime.now();
    
    if (lastSeenString.isNotEmpty) {
      DateTime? isoDate = DateTime.tryParse(lastSeenString);
      
      if (isoDate != null) {
        parsedLastSeen = isoDate.toLocal();
      } else {
        try {
          parsedLastSeen = _customFormat.parse(lastSeenString, true).toLocal();
        } catch (e) {
          print('Error parsing date "$lastSeenString": $e');
        }
      }
    }

    return Friendship(
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
      gameTitle: json['roomTitle'] ?? '', 
      lastSeen: parsedLastSeen,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'roomTitle': gameTitle,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
}
