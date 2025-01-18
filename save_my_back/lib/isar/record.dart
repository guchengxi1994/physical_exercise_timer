import 'package:isar/isar.dart';

part 'record.g.dart';

@collection
class PoseRecord {
  late int poseState;

  Id id = Isar.autoIncrement;
  int createAt = DateTime.now().millisecondsSinceEpoch;
}

List<PoseRecord> getLastOneHourRecords(Isar isar) {
  final now = DateTime.now();
  final oneHourAgo = now.subtract(const Duration(hours: 1));
  final oneHourAgoMillis = oneHourAgo.millisecondsSinceEpoch;
  return isar.poseRecords
      .filter()
      .createAtGreaterThan(oneHourAgoMillis)
      .findAllSync();
}

saveRecord(Isar isar, PoseRecord record) {
  isar.writeTxnSync(() {
    isar.poseRecords.putSync(record);
  });
}

saveBatchRecords(Isar isar, List<PoseRecord> records) {
  isar.writeTxnSync(() {
    isar.poseRecords.putAllSync(records);
  });
}
