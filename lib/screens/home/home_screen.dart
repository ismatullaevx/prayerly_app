import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/prayer_card.dart';
import '../../models/prayer.dart';
import '../../core/next_prayer_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return loc.get('goodMorning');
    } else if (hour < 17) {
      return loc.get('goodAfternoon');
    } else {
      return loc.get('goodEvening');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyPrayers = ref.watch(dailyPrayersProvider);
    final todayRecord = ref.watch(todayRecordProvider);
    final nextPrayerInfo = ref.watch(nextPrayerProvider);
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    int completedCount = 0;
    if (todayRecord.isFajrCompleted) completedCount++;
    if (todayRecord.isDhuhrCompleted) completedCount++;
    if (todayRecord.isAsrCompleted) completedCount++;
    if (todayRecord.isMaghribCompleted) completedCount++;
    if (todayRecord.isIshaCompleted) completedCount++;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('appTitle')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: dailyPrayers.when(
          data: (prayers) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              children: [
                // Greeting and Date
                Text(
                  _getGreeting(loc),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMMEEEEd(locale).format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Next Prayer Section
                Text(
                  loc.get('nextPrayer').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (nextPrayerInfo.prayer != null) ...[
                  Text(
                    '${loc.get(nextPrayerInfo.prayer!.name.toLowerCase())}${nextPrayerInfo.isTomorrow ? ' (${loc.get('tomorrow')})' : ''}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nextPrayerInfo.prayer!.time,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nextPrayerInfo.remaining.inHours}h ${nextPrayerInfo.remaining.inMinutes.remainder(60)}m ${loc.get('remaining')}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),

                // Today's Prayers List
                Text(
                  loc.get('todaysPrayers').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Card( // Wrap the list in a single subtle card instead of individual cards
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: prayers.map((prayer) {
                      bool isCompleted = false;
                      switch (prayer.type) {
                        case PrayerType.fajr:
                          isCompleted = todayRecord.isFajrCompleted;
                          break;
                        case PrayerType.dhuhr:
                          isCompleted = todayRecord.isDhuhrCompleted;
                          break;
                        case PrayerType.asr:
                          isCompleted = todayRecord.isAsrCompleted;
                          break;
                        case PrayerType.maghrib:
                          isCompleted = todayRecord.isMaghribCompleted;
                          break;
                        case PrayerType.isha:
                          isCompleted = todayRecord.isIshaCompleted;
                          break;
                      }

                      return Column(
                        children: [
                          PrayerCard(
                            prayer: prayer,
                            isCompleted: isCompleted,
                            onTap: () {
                              ref.read(todayRecordProvider.notifier).togglePrayer(prayer.type);
                            },
                          ),
                          if (prayer != prayers.last)
                            const Divider(height: 1, indent: 24, endIndent: 24),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Progress Section
                Center(
                  child: Text(
                    '$completedCount / 5 ${loc.get('prayersCompleted')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.get('locationError'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(dailyPrayersProvider);
                          ref.read(locationNotifierProvider.notifier).refreshLocation();
                        },
                        child: Text(loc.get('tryAgain')),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () => Geolocator.openAppSettings(),
                        child: Text(loc.get('openSettings')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
