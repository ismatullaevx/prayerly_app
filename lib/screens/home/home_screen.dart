import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../core/providers.dart';
import '../../core/next_prayer_provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/prayer_card.dart';
import '../../models/prayer.dart';

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

  String _formatRemaining(Duration duration, String remainingLabel, bool isRu) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final hSuffix = isRu ? 'ч' : 'h';
    final mSuffix = isRu ? 'м' : 'm';
    if (hours > 0) {
      return '$hours$hSuffix $minutes$mSuffix $remainingLabel';
    }
    return '$minutes$mSuffix $remainingLabel';
  }

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations loc,
    String locale,
    NextPrayerInfo nextPrayerInfo,
  ) {
    final hasPrayer = nextPrayerInfo.prayer != null;
    final prayerName = hasPrayer
        ? '${loc.get(nextPrayerInfo.prayer!.type.name)}${nextPrayerInfo.isTomorrow ? ' (${loc.get('tomorrow')})' : ''}'
        : loc.get('completedForToday');

    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 28.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3E3B), Color(0xFF072422)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3E3B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Background artwork using the icon image
            Positioned(
              right: -15,
              top: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  'assets/icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Gradient overlay for seamless text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F3E3B).withValues(alpha: 0.95),
                      const Color(0xFF0F3E3B).withValues(alpha: 0.72),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.58, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Banner Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      loc.get('nextPrayer').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE2D6C0),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prayerName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (hasPrayer) ...[
                    const SizedBox(height: 2),
                    Text(
                      nextPrayerInfo.prayer!.time,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Color(0xFFE2D6C0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatRemaining(
                              nextPrayerInfo.remaining,
                              loc.get('remaining'),
                              locale == 'ru',
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE2D6C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/icon.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(loc.get('appTitle')),
          ],
        ),
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
                
                // Hero Banner with icon artwork & Next Prayer
                _buildHeroBanner(context, loc, locale, nextPrayerInfo),

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
