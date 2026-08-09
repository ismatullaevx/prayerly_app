import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/prayer.dart';
import 'providers.dart';

class NextPrayerInfo {
  final Prayer? prayer;
  final Duration remaining;
  final bool isTomorrow;

  NextPrayerInfo({
    this.prayer,
    required this.remaining,
    this.isTomorrow = false,
  });
}

class NextPrayerNotifier extends StateNotifier<NextPrayerInfo> {
  final List<Prayer> _prayers;
  Timer? _timer;

  NextPrayerNotifier(this._prayers) : super(_calculateNext(_prayers)) {
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      state = _calculateNext(_prayers);
    });
  }

  static NextPrayerInfo _calculateNext(List<Prayer> prayers) {
    if (prayers.isEmpty) {
      return NextPrayerInfo(remaining: Duration.zero);
    }

    final now = DateTime.now();
    final format = DateFormat.jm();

    for (var prayer in prayers) {
      try {
        final parsedTime = format.parse(prayer.time);
        final prayerDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        if (prayerDateTime.isAfter(now)) {
          return NextPrayerInfo(
            prayer: prayer,
            remaining: prayerDateTime.difference(now),
          );
        }
      } catch (e) {
        // Ignore parse errors
      }
    }

    // If all passed, calculate time until tomorrow's Fajr
    try {
      final fajrTime = format.parse(prayers.first.time);
      final nextFajrDateTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        fajrTime.hour,
        fajrTime.minute,
      );
      final tomorrowFajr = Prayer(
        type: prayers.first.type,
        name: prayers.first.name,
        time: prayers.first.time,
      );

      return NextPrayerInfo(
        prayer: tomorrowFajr,
        remaining: nextFajrDateTime.difference(now),
        isTomorrow: true,
      );
    } catch (e) {
      return NextPrayerInfo(remaining: Duration.zero, isTomorrow: false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final nextPrayerProvider = StateNotifierProvider.autoDispose<NextPrayerNotifier, NextPrayerInfo>((ref) {
  final prayersAsync = ref.watch(dailyPrayersProvider);
  return prayersAsync.when(
    data: (prayers) => NextPrayerNotifier(prayers),
    loading: () => NextPrayerNotifier([]),
    error: (_, __) => NextPrayerNotifier([]),
  );
});
