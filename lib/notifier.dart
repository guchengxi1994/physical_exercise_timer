import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:physical_exercise_timer/local_storage.dart';

import 'state.dart';

class AppNotifier extends AutoDisposeNotifier<AppState> {
  final storage = LocalStorage();

  @override
  AppState build() {
    return AppState(
        duration: storage.getDuration(),
        execDuration: storage.getExecDuration(),
        notificationType: NotificationType.fromType(storage.getType()));
  }

  changeDuration(int duration) async {
    if (duration <= 0) {
      return;
    }

    await storage.setDuration(duration);

    state = state.copyWith(duration: duration);
  }

  changeExecDuration(int duration) async {
    if (duration <= 0) {
      return;
    }
    await storage.setExecDuration(duration);

    state = state.copyWith(execDuration: duration);
  }

  changeType(NotificationType type) async {
    await storage.setNotification(type.id);

    state = state.copyWith(notificationType: type);
  }
}

final appProvider = AutoDisposeNotifierProvider<AppNotifier, AppState>(
  () => AppNotifier(),
);
