import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import '../services/storage_service.dart';
import '../services/hive_service.dart';
import '../services/mock_prayer_service.dart';
import '../services/location_service.dart';
import '../services/real_prayer_service.dart';
import '../models/prayer.dart';
import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';

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

class CalculationMethodNotifier extends StateNotifier<String> {
  final StorageService _storageService;

  CalculationMethodNotifier(this._storageService) : super(_storageService.getCalculationMethod());

  void setMethod(String method) {
    state = method;
    _storageService.saveCalculationMethod(method);
  }
}

final calculationMethodProvider = StateNotifierProvider<CalculationMethodNotifier, String>((ref) {
  return CalculationMethodNotifier(ref.watch(storageServiceProvider));
});

class MadhabNotifier extends StateNotifier<String> {
  final StorageService _storageService;

  MadhabNotifier(this._storageService) : super(_storageService.getMadhab());

  void setMadhab(String madhab) {
    state = madhab;
    _storageService.saveMadhab(madhab);
  }
}

final madhabProvider = StateNotifierProvider<MadhabNotifier, String>((ref) {
  return MadhabNotifier(ref.watch(storageServiceProvider));
});

class LocationState {
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String? errorMessage;
  final bool isLoading;

  LocationState({
    this.latitude,
    this.longitude,
    this.cityName,
    this.errorMessage,
    this.isLoading = false,
  });
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(LocationState(isLoading: true)) {
    refreshLocation();
  }

  Future<void> refreshLocation() async {
    state = LocationState(isLoading: true, latitude: state.latitude, longitude: state.longitude, cityName: state.cityName);
    
    final result = await _locationService.getCurrentLocation();
    
    if (result.isSuccess && result.latitude != null && result.longitude != null) {
      String? city;
      try {
        final placemarks = await placemarkFromCoordinates(result.latitude!, result.longitude!);
        if (placemarks.isNotEmpty) {
          city = placemarks.first.locality ?? placemarks.first.administrativeArea;
        }
      } catch (e) {
        // Geocoding failed, ignore
      }
      
      state = LocationState(
        latitude: result.latitude,
        longitude: result.longitude,
        cityName: city,
        isLoading: false,
      );
    } else {
      state = LocationState(
        errorMessage: result.errorMessage,
        isLoading: false,
      );
    }
  }
}

final locationNotifierProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref.watch(locationServiceProvider));
});

// Providers for prayer data
final dailyPrayersProvider = FutureProvider<List<Prayer>>((ref) async {
  final locationState = ref.watch(locationNotifierProvider);
  final calcMethod = ref.watch(calculationMethodProvider);
  final madhabStr = ref.watch(madhabProvider);
  final realPrayerService = ref.watch(realPrayerServiceProvider);
  final mockService = ref.watch(mockPrayerServiceProvider);

  if (locationState.latitude != null && locationState.longitude != null) {
    try {
      return realPrayerService.calculatePrayers(
        locationState.latitude!, 
        locationState.longitude!,
        calcMethod,
        madhabStr,
      );
    } catch (e) {
      throw Exception('Unable to get prayer times');
    }
  } else {
    if (locationState.isLoading) {
      // Just return a future that never completes or wait. 
      // Actually, if it's loading we can just throw to show error or wait. 
      // Let's throw a temporary message or just use the error message.
      throw Exception('Loading location...');
    }
    throw Exception('Unable to get prayer times\n${locationState.errorMessage ?? ""}');
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

// Notifications
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

class NotificationSettingsState {
  final bool globalEnabled;
  final Map<String, bool> prayerSettings;

  NotificationSettingsState({
    required this.globalEnabled,
    required this.prayerSettings,
  });

  NotificationSettingsState copyWith({
    bool? globalEnabled,
    Map<String, bool>? prayerSettings,
  }) {
    return NotificationSettingsState(
      globalEnabled: globalEnabled ?? this.globalEnabled,
      prayerSettings: prayerSettings ?? this.prayerSettings,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  final StorageService _storageService;
  
  NotificationSettingsNotifier(this._storageService) : super(_loadState(_storageService));

  static NotificationSettingsState _loadState(StorageService storageService) {
    return NotificationSettingsState(
      globalEnabled: storageService.getNotificationsEnabled(),
      prayerSettings: {
        'Fajr': storageService.getPrayerNotification('fajr'),
        'Dhuhr': storageService.getPrayerNotification('dhuhr'),
        'Asr': storageService.getPrayerNotification('asr'),
        'Maghrib': storageService.getPrayerNotification('maghrib'),
        'Isha': storageService.getPrayerNotification('isha'),
      },
    );
  }

  void setGlobalEnabled(bool enabled) {
    _storageService.saveNotificationsEnabled(enabled);
    state = state.copyWith(globalEnabled: enabled);
  }

  void setPrayerEnabled(String prayerName, bool enabled) {
    _storageService.savePrayerNotification(prayerName.toLowerCase(), enabled);
    
    final newSettings = Map<String, bool>.from(state.prayerSettings);
    newSettings[prayerName] = enabled;
    
    state = state.copyWith(prayerSettings: newSettings);
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  return NotificationSettingsNotifier(ref.watch(storageServiceProvider));
});

final notificationSchedulerProvider = Provider<void>((ref) {
  final prayersAsyncValue = ref.watch(dailyPrayersProvider);
  final settings = ref.watch(notificationSettingsProvider);
  final languageCode = ref.watch(languageProvider);
  
  prayersAsyncValue.whenData((prayers) {
    final notificationService = ref.read(notificationServiceProvider);
    final loc = AppLocalizations(Locale(languageCode));
    
    notificationService.schedulePrayerNotifications(
      prayers,
      settings.globalEnabled,
      settings.prayerSettings,
      loc.get,
    );
  });
});
