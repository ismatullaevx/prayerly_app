import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Prayerly',
      'home': 'Home',
      'history': 'History',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'prayersCompleted': 'prayers completed',
      'fajr': 'Fajr',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
    },
    'ru': {
      'appTitle': 'Prayerly',
      'home': 'Главная',
      'history': 'История',
      'settings': 'Настройки',
      'language': 'Язык',
      'theme': 'Тема',
      'light': 'Светлая',
      'dark': 'Темная',
      'system': 'Системная',
      'prayersCompleted': 'молитв выполнено',
      'fajr': 'Фаджр',
      'dhuhr': 'Зухр',
      'asr': 'Аср',
      'maghrib': 'Магриб',
      'isha': 'Иша',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
