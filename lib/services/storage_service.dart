import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _calculationMethodKey = 'calculation_method';
  static const String _madhabKey = 'madhab';

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

  Future<void> saveCalculationMethod(String method) async {
    await _prefs.setString(_calculationMethodKey, method);
  }

  String getCalculationMethod() {
    return _prefs.getString(_calculationMethodKey) ?? 'muslim_world_league';
  }

  Future<void> saveMadhab(String madhab) async {
    await _prefs.setString(_madhabKey, madhab);
  }

  String getMadhab() {
    return _prefs.getString(_madhabKey) ?? 'shafi';
  }

  // Notifications
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _fajrNotificationKey = 'fajr_notification';
  static const String _dhuhrNotificationKey = 'dhuhr_notification';
  static const String _asrNotificationKey = 'asr_notification';
  static const String _maghribNotificationKey = 'maghrib_notification';
  static const String _ishaNotificationKey = 'isha_notification';

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
