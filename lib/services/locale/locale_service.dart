import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String globalLangCode = 'en';

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
    String? savedCode = _prefs!.getString(_key);

    if (savedCode != null) {
      _locale = Locale(savedCode);
    } else {
      String deviceCode = PlatformDispatcher.instance.locale.languageCode.split('_')[0];

      if (['en', 'ru', 'az', 'tr'].contains(deviceCode)) {
        _locale = Locale(deviceCode);
        globalLangCode = deviceCode;
      } else {
        _locale = const Locale('ru');
      }
    }
  }

  Future<void> setLocale(String code) async {
    if (!['en', 'ru', 'az', 'tr'].contains(code)) return;

    _locale = Locale(code);
    await _prefs!.setString(_key, code);
    notifyListeners(); // triggers rebuild in MaterialApp
  }
}
