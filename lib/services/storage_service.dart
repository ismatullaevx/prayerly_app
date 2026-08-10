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

  // Notifications
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> savePrayerNotification(String prayerId, bool enabled) async {
    await _prefs.setBool('${prayerId}_notification', enabled);
  }

  bool getPrayerNotification(String prayerId) {
    return _prefs.getBool('${prayerId}_notification') ?? true;
  }
}
