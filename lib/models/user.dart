import 'package:mafia_classic/services/cache/general_cache_service.dart';

class User {
  final int id;
  final String email;
  final String nickname;
  final String avatarUrl;
  final String accessToken;
  final String refreshToken;
  final DateTime expirationDate;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.avatarUrl,
    required this.accessToken, 
    required this.refreshToken, 
    required this.expirationDate,
  });
}