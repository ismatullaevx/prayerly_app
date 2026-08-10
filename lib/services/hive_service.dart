import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer.dart';

class HiveService {
  static const String _prayerBox = 'prayer_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PrayerRecordAdapter());
    await Hive.openBox<PrayerRecord>(_prayerBox);
  }

  Box<PrayerRecord> get _box => Hive.box<PrayerRecord>(_prayerBox);

  PrayerRecord? getRecordForDate(DateTime date) {
    // Generate an ID based on date YYYY-MM-DD
    final id = _generateId(date);
    return _box.get(id);
  }

  Future<void> saveRecord(PrayerRecord record) async {
    await _box.put(record.id, record);
  }

  List<PrayerRecord> getAllRecords() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> clearAllData() async {
    await _box.clear();
  }

  String _generateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
