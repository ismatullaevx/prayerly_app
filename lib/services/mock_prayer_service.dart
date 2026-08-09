import '../models/prayer.dart';

class MockPrayerService {
  List<Prayer> getDailyPrayers() {
    return [
      Prayer(type: PrayerType.fajr, name: 'Fajr', time: '04:30 AM'),
      Prayer(type: PrayerType.dhuhr, name: 'Dhuhr', time: '01:15 PM'),
      Prayer(type: PrayerType.asr, name: 'Asr', time: '05:00 PM'),
      Prayer(type: PrayerType.maghrib, name: 'Maghrib', time: '07:45 PM'),
      Prayer(type: PrayerType.isha, name: 'Isha', time: '09:15 PM'),
    ];
  }
}
