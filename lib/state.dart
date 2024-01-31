// ignore_for_file: constant_identifier_names

enum NotificationType {
  ToastInApp(0),
  Notification(1),
  Lock(2);

  const NotificationType(this.id);
  final int id;

  int getType() {
    return id;
  }

  static NotificationType fromType(int i) {
    if (i == 0) {
      return NotificationType.ToastInApp;
    } else if (i == 1) {
      return NotificationType.Notification;
    } else {
      return NotificationType.Lock;
    }
  }

  @override
  String toString() {
    switch (this) {
      case NotificationType.ToastInApp:
        return "Toast";
      case NotificationType.Notification:
        return "Notification";
      case NotificationType.Lock:
        return "Lock";
    }
  }
}

class AppState {
  int duration;
  int execDuration;
  NotificationType notificationType;

  AppState(
      {required this.duration,
      required this.execDuration,
      required this.notificationType});

  AppState copyWith(
      {int? duration, int? execDuration, NotificationType? notificationType}) {
    return AppState(
        duration: duration ?? this.duration,
        execDuration: execDuration ?? this.execDuration,
        notificationType: notificationType ?? this.notificationType);
  }
}
