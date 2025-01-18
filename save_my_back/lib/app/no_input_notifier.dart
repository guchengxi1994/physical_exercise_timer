import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:save_my_back/config.dart';

class NoInputState {
  final int initialTime;
  // 休息时间
  final int restTime;
  final int workTime;

  NoInputState({
    required this.initialTime,
    this.restTime = 0,
    this.workTime = 0,
  });

  NoInputState copyWith({
    int? initialTime,
    int? restTime,
    int? workTime,
  }) {
    return NoInputState(
      initialTime: initialTime ?? this.initialTime,
      restTime: restTime ?? this.restTime,
      workTime: workTime ?? this.workTime,
    );
  }
}

class NoInputNotifier extends Notifier<NoInputState> {
  @override
  NoInputState build() {
    return NoInputState(
      initialTime: DateTime.now().millisecondsSinceEpoch,
    );
  }

  updateGap(int gap) {
    if (gap > CONFIG.recordPeriod) {
      final rest = state.restTime + CONFIG.recordPeriod;
      state = state.copyWith(
        restTime: rest,
      );
    } else {
      final work = state.workTime + (CONFIG.recordPeriod - gap);
      state = state.copyWith(
        workTime: work,
      );
    }
  }
}

final noInputNotifierProvider =
    NotifierProvider<NoInputNotifier, NoInputState>(NoInputNotifier.new);
