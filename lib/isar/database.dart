import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physical_exercise_timer/isar/record.dart';
import 'package:physical_exercise_timer/local_storage.dart';

class IsarDatabase {
  // ignore: avoid_init_to_null
  late Isar? isar = null;

  static final _instance = IsarDatabase._init();

  factory IsarDatabase() => _instance;

  IsarDatabase._init();

  late List<CollectionSchema<Object>> schemas = [RecordSchema];

  Future initialDatabase() async {
    if (isar != null && isar!.isOpen) {
      return;
    }
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open(
      schemas,
      name: "DontSitAllDay",
      directory: dir.path,
    );
  }

  final LocalStorage _localStorage = LocalStorage();

  Future record(RecordType type) async {
    await isar!.writeTxn(() async {
      final last = await isar!.records.where().sortByCreateAtDesc().findFirst();
      int duration;
      if (last == null) {
        duration = 0;
      } else {
        duration =
            (DateTime.now().millisecondsSinceEpoch - last.createAt) ~/ 1000;
      }

      final Record record = Record()
        ..duration = duration
        ..recordType = type
        ..settedBreakTime = _localStorage.getExecDuration();

      await isar!.records.put(record);
    });
  }

  Future<List<Record>> getToday(
      {bool breakOnly = false, bool workOnly = false}) async {
    final now = DateTime.now();

    final today0 = DateTime(now.year, now.month, now.day);
    final today1 = today0.add(const Duration(days: 1));

    return getCertainTime(
        today0.millisecondsSinceEpoch, today1.millisecondsSinceEpoch,
        breakOnly: breakOnly, workOnly: workOnly);
  }

  List<(Record?, Record?)> getGroups(List<Record> records) {
    int i = 0;
    List<(Record?, Record?)> results = [];
    while (i < records.length) {
      if (records[i].recordType == RecordType.Work) {
        if (i + 1 < records.length &&
            records[i + 1].recordType == RecordType.Break) {
          results.add((records[i], records[i + 1]));
          i = i + 2;
          continue;
        } else {
          results.add((records[i], null));
          i = i + 1;
          continue;
        }
      } else {
        results.add((null, records[i]));
        i = i + 1;
        continue;
      }
    }

    return results;
  }

  int getMaxDuration(List<Record> records) {
    int max = 0;
    for (final i in records) {
      if (i.duration > max) {
        max = i.duration;
      }
    }
    return max;
  }

  Future<List<Record>> getCertainTime(int starttime, int endtime,
      {bool breakOnly = false, bool workOnly = false}) async {
    assert(breakOnly == false || workOnly == true);

    final List<Record> records = await isar!.records
        .filter()
        .createAtBetween(starttime, endtime)
        .findAll();

    if (breakOnly) {
      return records
          .where((element) => element.recordType == RecordType.Break)
          .toList();
    }

    if (workOnly) {
      return records
          .where((element) => element.recordType == RecordType.Work)
          .toList();
    }

    return records;
  }
}
