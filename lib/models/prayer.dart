import 'package:hive/hive.dart';

class PrayerRecord extends HiveObject {
  final String id;
  final DateTime date;
  bool isFajrCompleted;
  bool isDhuhrCompleted;
  bool isAsrCompleted;
  bool isMaghribCompleted;
  bool isIshaCompleted;

  PrayerRecord({
    required this.id,
    required this.date,
    this.isFajrCompleted = false,
    this.isDhuhrCompleted = false,
    this.isAsrCompleted = false,
    this.isMaghribCompleted = false,
    this.isIshaCompleted = false,
  });
}

class PrayerRecordAdapter extends TypeAdapter<PrayerRecord> {
  @override
  final int typeId = 0;

  @override
  PrayerRecord read(BinaryReader reader) {
    return PrayerRecord(
      id: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isFajrCompleted: reader.readBool(),
      isDhuhrCompleted: reader.readBool(),
      isAsrCompleted: reader.readBool(),
      isMaghribCompleted: reader.readBool(),
      isIshaCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerRecord obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isFajrCompleted);
    writer.writeBool(obj.isDhuhrCompleted);
    writer.writeBool(obj.isAsrCompleted);
    writer.writeBool(obj.isMaghribCompleted);
    writer.writeBool(obj.isIshaCompleted);
  }
}

enum PrayerType {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

class Prayer {
  final PrayerType type;
  final String name;
  final String time; // e.g. "05:30 AM"

  Prayer({
    required this.type,
    required this.name,
    required this.time,
  });
}
