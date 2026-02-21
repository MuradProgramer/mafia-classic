import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const _key = 'language_code';
  static LocaleService? _instance;

  LocaleService._internal();
  factory LocaleService() => _instance ??= LocaleService._internal();

  SharedPreferences? _prefs;
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();

    // Read saved language
    String? code = _prefs!.getString(_key);

    // fallback to device language
    code ??= PlatformDispatcher.instance.locale.languageCode;

    // validate
    if (!['en', 'ru', 'az', 'tr'].contains(code)) {
      code = 'ru';
    }

    _locale = Locale(code);
  }

  Future<void> setLocale(String code) async {
    if (!['en', 'ru', 'az', 'tr'].contains(code)) return;

    _locale = Locale(code);
    await _prefs!.setString(_key, code);
    notifyListeners(); // triggers rebuild in MaterialApp
  }
}
