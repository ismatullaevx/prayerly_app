import 'package:adhan/adhan.dart' as adhan;
import '../models/prayer.dart';
import 'package:intl/intl.dart';

class RealPrayerService {
  List<Prayer> calculatePrayers(double latitude, double longitude, String calcMethodStr, String madhabStr) {
    try {
      final coordinates = adhan.Coordinates(latitude, longitude);
      
      adhan.CalculationMethod method;
      switch (calcMethodStr) {
        case 'egyptian':
          method = adhan.CalculationMethod.egyptian;
          break;
        case 'karachi':
          method = adhan.CalculationMethod.karachi;
          break;
        case 'umm_al_qura':
          method = adhan.CalculationMethod.ummAlQura;
          break;
        case 'dubai':
          method = adhan.CalculationMethod.dubai;
          break;
        case 'moonsighting_committee':
          method = adhan.CalculationMethod.moonSightingCommittee;
          break;
        case 'muslim_world_league':
        default:
          method = adhan.CalculationMethod.muslimWorldLeague;
          break;
      }
      final params = method.getParameters();

      if (madhabStr == 'hanafi') {
        params.madhab = adhan.Madhab.hanafi;
      } else {
        params.madhab = adhan.Madhab.shafi;
      }

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
