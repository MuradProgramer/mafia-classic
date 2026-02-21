import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';

extension LanguagePrefs on SharedPrefsService {
  Future<void> saveLanguageCode(String code) async {
    await setString('language_code', code);
  }

  String? getSavedLanguageCode() {
    return getString('language_code');
  }
}
