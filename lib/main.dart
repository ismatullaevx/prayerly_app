import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme.dart';
import 'core/providers.dart';
import 'core/localization/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const PrayerlyApp(),
    ),
  );
}

class PrayerlyApp extends ConsumerWidget {
  const PrayerlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeString = ref.watch(themeProvider);
    final languageString = ref.watch(languageProvider);

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
      home: const MainScreen(),
    );
  }
}
