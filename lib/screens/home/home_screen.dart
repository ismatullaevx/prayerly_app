import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/prayer_card.dart';
import '../../models/prayer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyPrayers = ref.watch(dailyPrayersProvider);
    final todayRecord = ref.watch(todayRecordProvider);
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Calculate completed count
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Text(
                    DateFormat.yMMMMEEEEd(locale).format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$completedCount / 5 ${loc.get('prayersCompleted')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: dailyPrayers.when(
                data: (prayers) {
                  return ListView.builder(
                    itemCount: prayers.length,
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
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

                      return PrayerCard(
                        prayer: prayer,
                        isCompleted: isCompleted,
                        onTap: () {
                          ref.read(todayRecordProvider.notifier).togglePrayer(prayer.type);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Unable to get prayer times',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(dailyPrayersProvider);
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
