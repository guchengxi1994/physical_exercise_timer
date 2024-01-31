import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final _instance = LocalStorage._init();

  factory LocalStorage() => _instance;

  LocalStorage._init();

  // ignore: avoid_init_to_null
  late SharedPreferences? _storage = null;

  initStorage() async {
    _storage ??= await SharedPreferences.getInstance();
  }

  int getDuration() {
    return _storage!.getInt("duration") ?? /* 1 hour */ 60 * 60;
  }

  Future setDuration(int duration) async {
    if (duration < 0) {
      return;
    }
    await _storage!.setInt("duration", duration);
  }

  int getExecDuration() {
    return _storage!.getInt("execDuraion") ?? /* 10 min */ 10 * 60;
  }

  Future setExecDuration(int duration) async {
    if (duration < 0) {
      return;
    }
    await _storage!.setInt("execDuraion", duration);
  }

  int getType() {
    return _storage!.getInt("notification") ?? 2;
  }

  Future setNotification(int notif) async {
    assert(notif >= 0 && notif <= 2);
    await _storage!.setInt("notification", notif);
  }
}
