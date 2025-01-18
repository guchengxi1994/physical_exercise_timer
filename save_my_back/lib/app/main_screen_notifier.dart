import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:save_my_back/config.dart';
import 'package:save_my_back/constants.dart';
import 'package:save_my_back/src/rust/api/detector.dart';
import 'package:save_my_back/utils/logger.dart';
import 'package:window_manager/window_manager.dart';

import 'chart_notifier.dart';
import 'main_screen_state.dart';

class MainScreenNotifier extends AutoDisposeAsyncNotifier<MainScreenState> {
  late StreamController<(Uint8List, Uint8List, String)?> streamController =
      StreamController();

  Stream<(Uint8List, Uint8List, String)?> get stream => streamController.stream;

  // ignore: avoid_init_to_null
  late Timer? timer = null;

  @override
  FutureOr<MainScreenState> build() async {
    final isMaximized = await windowManager.isMaximized();
    final cameraIndex = await _fetchCameras();

    ref.onDispose(() async {
      if (state.value!.cameraId != -1) {
        await CameraPlatform.instance.dispose(state.value!.cameraId);
      }
      timer?.cancel();
      streamController.close();
    });

    return MainScreenState(
      isMaximized: isMaximized,
      isCameraAvailable: cameraIndex != -1,
      isCameraReady: false,
      cameraId: -1,
    );
  }

  void toggle() async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      if (state.value!.isMaximized) {
        await windowManager.setSize(minSize);
      } else {
        await windowManager.setSize(maxSize);
      }
      await Future.delayed(Duration(milliseconds: 500));
      return state.value!.copyWith(isMaximized: !state.value!.isMaximized);
    });
  }

  final MediaSettings _mediaSettings = const MediaSettings(
    resolutionPreset: ResolutionPreset.low,
    fps: 15,
    videoBitrate: 200000,
    audioBitrate: 32000,
    enableAudio: true,
  );

  void initCamera() async {
    if (state.value!.cameraId != -1) {
      await CameraPlatform.instance.dispose(state.value!.cameraId);
    }

    final cameras = await CameraPlatform.instance.availableCameras();
    final CameraDescription camera = cameras.first;
    final cameraId = await CameraPlatform.instance.createCameraWithSettings(
      camera,
      _mediaSettings,
    );

    logger.d("initCamera: $cameraId");

    await CameraPlatform.instance.initializeCamera(
      cameraId,
    );
    state = await AsyncValue.guard(() async {
      return state.value!.copyWith(isCameraReady: true, cameraId: cameraId);
    });

    timer =
        Timer.periodic(Duration(seconds: CONFIG.recordPeriod), (timer) async {
      final image = await CameraPlatform.instance.takePicture(cameraId);
      final imgBytes = await image.readAsBytes();
      final inferenceResult = await infer(imgBytes: imgBytes);
      if (inferenceResult == null) {
        return;
      }
      streamController.add((
        imgBytes,
        inferenceResult.$1,
        inferenceResult.$2.map((e) => getHint(state: e)).join("; ")
      ));
      ref.read(chartNotifierProvider.notifier).addRecords(inferenceResult.$2);
      logger.d("send to frontend");
    });
  }

  Future<int> _fetchCameras() async {
    List<CameraDescription> cameras = <CameraDescription>[];

    try {
      cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        // cameraInfo = 'No available cameras';
        logger.f('No available cameras');
        return -1;
      } else {
        return 0;
      }
    } on PlatformException catch (e) {
      logger.f('Failed to get cameras: ${e.code}: ${e.message}');
      return -1;
    }
  }
}

final mainScreenNotifierProvider =
    AutoDisposeAsyncNotifierProvider<MainScreenNotifier, MainScreenState>(
  MainScreenNotifier.new,
);
