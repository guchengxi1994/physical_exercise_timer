import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:save_my_back/isar/database.dart';
import 'package:save_my_back/isar/record.dart';
import 'package:save_my_back/src/rust/api/detector.dart';
import 'package:save_my_back/src/rust/yolo/utils.dart';

class ChartState {
  final List<PoseRecord> records;
  ChartState({required this.records});

  ChartState copyWith({List<PoseRecord>? records}) {
    return ChartState(records: records ?? this.records);
  }
}

class ChartNotifier extends Notifier<ChartState> {
  @override
  ChartState build() {
    final records = getLastOneHourRecords(IsarDatabase().isar!);
    return ChartState(records: records);
  }

  void addRecord(PoseState s) {
    final record = PoseRecord()..poseState = getPoseType(state: s).toInt();
    saveRecord(IsarDatabase().isar!, record);
    state =
        state.copyWith(records: getLastOneHourRecords(IsarDatabase().isar!));
  }

  void addRecords(List<PoseState> poses) {
    List<PoseRecord> records = [];
    for (final pose in poses) {
      records.add(PoseRecord()..poseState = getPoseType(state: pose).toInt());
    }
    saveBatchRecords(IsarDatabase().isar!, records);
    state =
        state.copyWith(records: getLastOneHourRecords(IsarDatabase().isar!));
  }

  List<FlSpot> stateToSpot() {
    Map<int, int> map = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
      8: 0,
      9: 0,
      10: 0,
    };

    for (final record in state.records) {
      map[record.poseState] = map[record.poseState]! + 1;
    }

    return map.entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();
  }
}

final chartNotifierProvider =
    NotifierProvider<ChartNotifier, ChartState>(ChartNotifier.new);
