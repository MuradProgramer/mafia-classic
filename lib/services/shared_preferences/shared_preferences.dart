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
}
