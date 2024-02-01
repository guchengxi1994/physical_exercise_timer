// ignore_for_file: constant_identifier_names

import 'package:isar/isar.dart';

part 'record.g.dart';

enum RecordType { Work, Break }

@collection
class Record {
  @enumerated
  late RecordType recordType;

  Id id = Isar.autoIncrement;
  int createAt = DateTime.now().millisecondsSinceEpoch;

  /*
    配置中的休息时间
  */
  late int settedBreakTime;

  late int duration;
}
