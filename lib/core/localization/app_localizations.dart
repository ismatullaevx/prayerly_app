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
      'location': 'Location',
      'refreshLocation': 'Refresh Location',
      'calculationMethod': 'Calculation Method',
      'madhab': 'Madhab',
      'shafi': 'Shafi',
      'hanafi': 'Hanafi',
      'muslim_world_league': 'Muslim World League',
      'egyptian': 'Egyptian',
      'karachi': 'Karachi',
      'umm_al_qura': 'Umm Al Qura',
      'dubai': 'Dubai',
      'moonsighting_committee': 'Moonsighting Committee',
      'unknownLocation': 'Unknown Location',
      'notifications': 'Notifications',
      'prayerReminders': 'Prayer reminders',
      'notificationBody': 'It\'s time for %s prayer.',
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
      'location': 'Местоположение',
      'refreshLocation': 'Обновить местоположение',
      'calculationMethod': 'Метод расчета',
      'madhab': 'Мазхаб',
      'shafi': 'Шафиитский',
      'hanafi': 'Ханафитский',
      'muslim_world_league': 'Всемирная исламская лига',
      'egyptian': 'Египетский',
      'karachi': 'Карачи',
      'umm_al_qura': 'Умм аль-Кура',
      'dubai': 'Дубай',
      'moonsighting_committee': 'Комитет по наблюдению за луной',
      'unknownLocation': 'Неизвестное местоположение',
      'notifications': 'Уведомления',
      'prayerReminders': 'Напоминания о намазе',
      'notificationBody': 'Время намаза %s.',
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
