import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final locationState = ref.watch(locationNotifierProvider);
    final calcMethod = ref.watch(calculationMethodProvider);
    final madhab = ref.watch(madhabProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          // APPEARANCE SECTION
          _buildCategoryHeader(loc.get('appearance'), context),
          _buildSettingsSection(
            title: loc.get('language'),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value != null) ref.read(languageProvider.notifier).setLanguage(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Русский'),
                    value: 'ru',
                    groupValue: currentLanguage,
                    onChanged: (value) {
                      if (value != null) ref.read(languageProvider.notifier).setLanguage(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: loc.get('theme'),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(loc.get('system')),
                    value: 'system',
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) ref.read(themeProvider.notifier).setTheme(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(loc.get('light')),
                    value: 'light',
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) ref.read(themeProvider.notifier).setTheme(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(loc.get('dark')),
                    value: 'dark',
                    groupValue: currentTheme,
                    onChanged: (value) {
                      if (value != null) ref.read(themeProvider.notifier).setTheme(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PRAYER SECTION
          _buildCategoryHeader(loc.get('prayer'), context),
          _buildSettingsSection(
            title: loc.get('location'),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: Text(locationState.isLoading 
                  ? '...'
                  : (locationState.cityName ?? locationState.errorMessage ?? loc.get('unknownLocation'))),
                trailing: locationState.errorMessage != null && locationState.errorMessage!.contains('permanently denied') 
                  ? IconButton(icon: const Icon(Icons.settings), onPressed: () => Geolocator.openAppSettings())
                  : IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(locationNotifierProvider.notifier).refreshLocation()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: loc.get('calculationMethod'),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var method in ['muslim_world_league', 'egyptian', 'karachi', 'umm_al_qura', 'dubai', 'moonsighting_committee'])
                    ...[
                      RadioListTile<String>(
                        title: Text(loc.get(method)),
                        value: method,
                        groupValue: calcMethod,
                        onChanged: (value) {
                          if (value != null) ref.read(calculationMethodProvider.notifier).setMethod(value);
                        },
                      ),
                      if (method != 'moonsighting_committee') const Divider(height: 1),
                    ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsSection(
            title: loc.get('madhab'),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(loc.get('shafi')),
                    value: 'shafi',
                    groupValue: madhab,
                    onChanged: (value) {
                      if (value != null) ref.read(madhabProvider.notifier).setMadhab(value);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(loc.get('hanafi')),
                    value: 'hanafi',
                    groupValue: madhab,
                    onChanged: (value) {
                      if (value != null) ref.read(madhabProvider.notifier).setMadhab(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),

          // NOTIFICATIONS SECTION
          _buildCategoryHeader(loc.get('notifications'), context),
          Card(
            margin: EdgeInsets.zero,
            child: Consumer(
              builder: (context, ref, child) {
                final notificationSettings = ref.watch(notificationSettingsProvider);
                return Column(
                  children: [
                    SwitchListTile(
                      title: Text(loc.get('prayerReminders')),
                      value: notificationSettings.globalEnabled,
                      onChanged: (value) {
                        ref.read(notificationSettingsProvider.notifier).setGlobalEnabled(value);
                      },
                    ),
                    if (notificationSettings.globalEnabled) ...[
                      const Divider(height: 1),
                      for (var prayer in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) ...[
                        SwitchListTile(
                          contentPadding: const EdgeInsets.only(left: 32, right: 16),
                          title: Text(loc.get(prayer.toLowerCase())),
                          value: notificationSettings.prayerSettings[prayer] ?? true,
                          onChanged: (value) {
                            ref.read(notificationSettingsProvider.notifier).setPrayerEnabled(prayer, value);
                          },
                        ),
                        if (prayer != 'Isha') const Divider(height: 1),
                      ]
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
