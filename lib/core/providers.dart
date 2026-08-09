import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/hive_service.dart';
import '../services/mock_prayer_service.dart';
import '../services/location_service.dart';
import '../services/real_prayer_service.dart';
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

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final realPrayerServiceProvider = Provider<RealPrayerService>((ref) {
  return RealPrayerService();
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
final dailyPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final realPrayerService = ref.watch(realPrayerServiceProvider);
  final mockService = ref.watch(mockPrayerServiceProvider);

  final locationResult = await locationService.getCurrentLocation();
  
  if (locationResult.isSuccess && locationResult.latitude != null && locationResult.longitude != null) {
    try {
      return realPrayerService.calculatePrayers(locationResult.latitude!, locationResult.longitude!);
    } catch (e) {
      throw Exception('Unable to get prayer times');
    }
  } else {
    // We throw an exception if location fails so the UI can show the error state.
    // If we wanted to fallback to mock on error, we could return mockService.getDailyPrayers() here.
    // However, the spec says: "If location or prayer calculation fails, show a simple error state: Unable to get prayer times"
    throw Exception('Unable to get prayer times\n${locationResult.errorMessage ?? ""}');
  }
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
  final todayRecord = ref.watch(todayRecordProvider);
  
  final allRecords = hiveService.getAllRecords();
  return allRecords.where((record) => record.id != todayRecord.id).toList();
});
