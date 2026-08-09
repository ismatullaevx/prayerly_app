import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/hive_service.dart';
import '../services/mock_prayer_service.dart';
import '../models/prayer.dart';

// Providers for services
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

final mockPrayerServiceProvider = Provider<MockPrayerService>((ref) {
  return MockPrayerService();
});

// State Notifiers
class ThemeNotifier extends StateNotifier<String> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService) : super(_storageService.getTheme());

  void setTheme(String theme) {
    state = theme;
    _storageService.saveTheme(theme);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier(ref.watch(storageServiceProvider));
});

class LanguageNotifier extends StateNotifier<String> {
  final StorageService _storageService;

  LanguageNotifier(this._storageService) : super(_storageService.getLanguage());

  void setLanguage(String lang) {
    state = lang;
    _storageService.saveLanguage(lang);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier(ref.watch(storageServiceProvider));
});

// Providers for prayer data
final dailyPrayersProvider = Provider<List<Prayer>>((ref) {
  return ref.watch(mockPrayerServiceProvider).getDailyPrayers();
});

class TodayRecordNotifier extends StateNotifier<PrayerRecord> {
  final HiveService _hiveService;
  final DateTime _today;

  TodayRecordNotifier(this._hiveService) : _today = DateTime.now(), super(_initRecord(_hiveService));

  static PrayerRecord _initRecord(HiveService hiveService) {
    final now = DateTime.now();
    final id = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return hiveService.getRecordForDate(now) ?? PrayerRecord(id: id, date: now);
  }

  void togglePrayer(PrayerType type) {
    final updatedRecord = PrayerRecord(
      id: state.id,
      date: state.date,
      isFajrCompleted: type == PrayerType.fajr ? !state.isFajrCompleted : state.isFajrCompleted,
      isDhuhrCompleted: type == PrayerType.dhuhr ? !state.isDhuhrCompleted : state.isDhuhrCompleted,
      isAsrCompleted: type == PrayerType.asr ? !state.isAsrCompleted : state.isAsrCompleted,
      isMaghribCompleted: type == PrayerType.maghrib ? !state.isMaghribCompleted : state.isMaghribCompleted,
      isIshaCompleted: type == PrayerType.isha ? !state.isIshaCompleted : state.isIshaCompleted,
    );
    state = updatedRecord;
    _hiveService.saveRecord(updatedRecord);
  }
}

final todayRecordProvider = StateNotifierProvider<TodayRecordNotifier, PrayerRecord>((ref) {
  return TodayRecordNotifier(ref.watch(hiveServiceProvider));
});

final historyRecordsProvider = Provider<List<PrayerRecord>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  // We trigger a watch on todayRecordProvider so that the history updates if today's record changes
  ref.watch(todayRecordProvider);
  return hiveService.getAllRecords();
});
