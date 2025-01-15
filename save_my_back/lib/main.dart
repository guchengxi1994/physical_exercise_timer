import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:save_my_back/src/rust/api/detector.dart';
import 'package:save_my_back/src/rust/frb_generated.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

import 'app/main_screen.dart';
import 'constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await RustLib.init();
  await initModels(
      modelPath:
          r"D:\github_repo\ai_tools\rust\assets\yolov8s-pose.safetensors");

  WindowOptions windowOptions = WindowOptions(
    size: minSize,
    minimumSize: minSize,
    maximumSize: maxSize,
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ToastificationWrapper(
    child: ProviderScope(child: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}
