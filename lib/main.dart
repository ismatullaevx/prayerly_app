import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/theme.dart';
import 'core/providers.dart';
import 'core/localization/app_localizations.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for intl
  await initializeDateFormatting();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

  bool isFirstLaunch = sharedPreferences.getBool('isFirstLaunch') ?? hiveService.getAllRecords().isEmpty;

  if (!isFirstLaunch) {
    await notificationService.requestPermissions();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveServiceProvider.overrideWithValue(hiveService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: PrayerlyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class PrayerlyApp extends ConsumerWidget {
  final bool isFirstLaunch;
  const PrayerlyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeString = ref.watch(themeProvider);
    final languageString = ref.watch(languageProvider);

    // Keep the scheduler alive
    ref.listen(notificationSchedulerProvider, (_, __) {});

    ThemeMode themeMode;
    switch (themeString) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp(
      title: 'Prayerly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(languageString),
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isFirstLaunch ? const OnboardingScreen() : const MainScreen(),
    );
  }
}
