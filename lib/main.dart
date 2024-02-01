import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:physical_exercise_timer/constants.dart';
import 'package:physical_exercise_timer/local_storage.dart';
import 'package:window_manager/window_manager.dart';

import 'isar/database.dart';
import 'ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await localNotifier.setup(
    appName: '久坐计时器',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(windowWidth, windowHeight),
    minimumSize: Size(windowWidth, windowHeight),
    maximumSize: Size(windowWidth, windowHeight),
    title: "Physical Exercise Timer",
    center: false,
    // backgroundColor: Colors.transparent,
  );
  windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final storage = LocalStorage();
  await storage.initStorage();
  final IsarDatabase database = IsarDatabase();
  await database.initialDatabase();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const UI(),
    );
  }
}
