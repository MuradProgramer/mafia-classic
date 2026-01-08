import 'dart:convert';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';

abstract class JsonModel {
  Map<String, dynamic> toJson();
}

class GeneralCacheService {
  static final GeneralCacheService _instance = GeneralCacheService._internal();
  factory GeneralCacheService() => _instance;
  GeneralCacheService._internal();

  final SharedPrefsService _prefs = SharedPrefsService();

  //? Save any primitive or model or list
  Future<void> save<T>(String key, T data) async {
    if (data == null) {
      await _prefs.remove(key);
      return;
    }

    if (_isPrimitive(data)) {
      await _savePrimitive(key, data);
      return;
    }

    if (data is JsonModel) {
      final jsonStr = jsonEncode(data.toJson());
      await _prefs.setString(key, jsonStr);
      return;
    }

    if (data is List) {
      await _saveList(key, data);
      return;
    }

    throw Exception("Unsupported type for caching: $T");
  }

  //? Load data
  T? load<T>(String key, T Function(dynamic json)? fromJson) {
    final stored = _prefs.getString(key);

    if (stored == null) return null;

    //? Primitive types
    if (T == String) return stored as T;
    if (T == int) return int.tryParse(stored) as T?;
    if (T == double) return double.tryParse(stored) as T?;
    if (T == bool) return (stored == "true") as T;

    final decoded = jsonDecode(stored);

    //? List case
    if (decoded is List) {
      if (fromJson == null) {
        throw Exception("fromJson is required for List<T>");
      }
      final mappedList = decoded.map((item) => fromJson(item)).toList();

      return mappedList as T;
      //return decoded.map((item) => fromJson(item)).toList() as T;
    }

    //? Single model
    if (fromJson != null) {
      return fromJson(decoded); // as T
    }

    throw Exception("fromJson function is required for complex types.");
  }

  List<T>? loadList<T>(String key, T Function(dynamic json) fromJson) {
    final stored = _prefs.getString(key);

    if (stored == null) return null;

    final decoded = jsonDecode(stored);

    if (decoded is List) {
      final mappedList = decoded.map((item) => fromJson(item)).toList();
      return mappedList;
    }

    return null;
  }
  // ------------------------------
  // Internals
  // ------------------------------

  bool _isPrimitive(dynamic value) =>
      value is String || value is int || value is double || value is bool;

  Future<void> _savePrimitive(String key, dynamic value) async {
    await _prefs.setString(key, value.toString());
  }

  Future<void> _saveList(String key, List data) async {
    if (data.isEmpty) {
      await _prefs.setString(key, jsonEncode([]));
      return;
    }

    if (data.first is JsonModel) {
      final list = data.map((e) => (e as JsonModel).toJson()).toList();
      await _prefs.setString(key, jsonEncode(list));
      return;
    }

    //? For list of primitives
    await _prefs.setString(key, jsonEncode(data));
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
