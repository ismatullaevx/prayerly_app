import 'package:adhan/adhan.dart' as adhan;
import '../models/prayer.dart';
import 'package:intl/intl.dart';

class RealPrayerService {
  List<Prayer> calculatePrayers(double latitude, double longitude) {
    try {
      final coordinates = adhan.Coordinates(latitude, longitude);
      
      // Step 3: Clean structure for calculation settings. 
      // Using sensible defaults for now (Muslim World League).
      final params = adhan.CalculationMethod.muslim_world_league.getParameters();
      params.madhab = adhan.Madhab.shafi; // Default to Shafi (standard)

      // Calculate for current local date (Step 4: Daily Refresh)
      final date = adhan.DateComponents.from(DateTime.now());

      final prayerTimes = adhan.PrayerTimes(coordinates, date, params);

      final format = DateFormat.jm(); // e.g. 5:30 AM

      return [
        Prayer(type: PrayerType.fajr, name: 'Fajr', time: format.format(prayerTimes.fajr)),
        Prayer(type: PrayerType.dhuhr, name: 'Dhuhr', time: format.format(prayerTimes.dhuhr)),
        Prayer(type: PrayerType.asr, name: 'Asr', time: format.format(prayerTimes.asr)),
        Prayer(type: PrayerType.maghrib, name: 'Maghrib', time: format.format(prayerTimes.maghrib)),
        Prayer(type: PrayerType.isha, name: 'Isha', time: format.format(prayerTimes.isha)),
      ];
    } catch (e) {
      // Return empty or throw, we will catch it in the provider.
      throw Exception('Failed to calculate prayer times');
    }
  }
}
