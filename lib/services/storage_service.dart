import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';

  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveTheme(String themeName) async {
    await _prefs.setString(_themeKey, themeName);
  }

  String getTheme() {
    return _prefs.getString(_themeKey) ?? 'system';
  }
}
