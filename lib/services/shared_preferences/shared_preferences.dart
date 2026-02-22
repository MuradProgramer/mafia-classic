import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  static SharedPreferences? _prefs;

  //? Initialize the SharedPreferences instance
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  //? Save a string value
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  //? Get a string value
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  //? Save an integer value
  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  //? Get an integer value
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  //? Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  //? Get a boolean value
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  //? Save a double value
  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  //? Get a double value
  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  //? Save a list of strings
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  //? Get a list of strings
  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  //? Remove a specific key
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  //? Clear all saved data
  Future<void> clear() async {
    await _prefs?.clear();
  }

  //! TOKENS
  static String? getAccessToken() =>
      _prefs?.getString('access_token');

  static String? getRefreshToken() =>
      _prefs?.getString('refresh_token');

  static String? getUserNickname() =>
      _prefs?.getString('user_nickname');

  static String? getUserAvatarUrl() =>
      _prefs?.getString('user_avatar_url');
  
  static String? getUserEmail() =>
      _prefs?.getString('user_email');

  static int? getUserId() =>
      _prefs?.getInt('user_id');

  static DateTime? getAccessTokenExpiryUtc() {
    final millis = _prefs?.getInt('token_expiration');
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      millis,
      isUtc: true,
    );
  }

  static Future<void> setAvatarUrl(String avatarUrl) async {
    await _prefs?.setString('user_avatar_url', avatarUrl);
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String nickname,
    required String avatarUrl,
    required String email,
    required int id,
    required String refreshToken,
    required DateTime expiration,
  }) async {
    await _prefs?.setString('access_token', accessToken);
    await _prefs?.setString('refresh_token', refreshToken);
    await _prefs?.setString('user_nickname', nickname);
    await _prefs?.setString('user_avatar_url', avatarUrl);
    await _prefs?.setString('user_email', email);
    await _prefs?.setInt('user_id', id);
    
    await _prefs?.setInt(
      'token_expiration',
      expiration.millisecondsSinceEpoch,
    );
  }

  static Future<void> clearAuth() async {
    await _prefs?.remove('access_token');
    await _prefs?.remove('refresh_token');
    await _prefs?.remove('token_expiration');
  }
}
