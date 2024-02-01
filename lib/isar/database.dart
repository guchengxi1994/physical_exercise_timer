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
}
