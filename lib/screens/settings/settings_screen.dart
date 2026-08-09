import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            title: loc.get('language'),
            child: Card(
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
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: loc.get('theme'),
            child: Card(
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
        ],
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
