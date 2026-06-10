import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:hive/hive.dart';

class BatteryHistoryStorage {
  static const _boxName = 'battery_history';

  // ── Box open karo (already open ho toh same return karega)
  static Future<Box<BatteryReadingHive>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<BatteryReadingHive>(_boxName);
    }
    return await Hive.openBox<BatteryReadingHive>(_boxName);
  }

  // ── Disk se history load karo
  static Future<List<BatteryReading>> load() async {
    try {
      final box = await _openBox();
      final cutoff = DateTime.now().subtract(const Duration(days: 30));

      // 30 din se purani readings skip karo
      return box.values
          .where((r) => r.time.isAfter(cutoff))
          .map((r) => BatteryReading(level: r.level, time: r.time))
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time)); // time order mein
    } catch (_) {
      return [];
    }
  }

  // ── Sirf naya reading append karo (poori list dobara likhne ki zaroorat nahi)
  static Future<void> append(BatteryReading reading) async {
    try {
      final box = await _openBox();
      await box.add(BatteryReadingHive(
        level: reading.level,
        time: reading.time,
      ));
    } catch (_) {}
  }

  // ── 30 din se purani readings Hive se hata do (cleanup)
  static Future<void> purgeOld() async {
    try {
      final box = await _openBox();
      final cutoff = DateTime.now().subtract(const Duration(days: 30));

      final oldKeys = box.keys
          .where((k) => box.get(k)!.time.isBefore(cutoff))
          .toList();

      await box.deleteAll(oldKeys);
    } catch (_) {}
  }

  // ── Sab kuch clear karo (debug ke liye)
  static Future<void> clear() async {
    try {
      final box = await _openBox();
      await box.clear();
    } catch (_) {}
  }
}


// ── BatteryReading Hive Model
// typeId: 0 — ek baar set karo, kabhi mat badlo
class BatteryReadingHive {
  final int level;
  final DateTime time;

  BatteryReadingHive({required this.level, required this.time});
}

// ── Manual TypeAdapter — build_runner ki zaroorat nahi
class BatteryReadingAdapter extends TypeAdapter<BatteryReadingHive> {
  @override
  final int typeId = 0;

  @override
  BatteryReadingHive read(BinaryReader reader) {
    return BatteryReadingHive(
      level: reader.readInt(),
      time: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, BatteryReadingHive obj) {
    writer.writeInt(obj.level);
    writer.writeInt(obj.time.millisecondsSinceEpoch);
  }
}