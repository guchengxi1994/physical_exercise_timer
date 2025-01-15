import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:he/he.dart';
import 'package:save_my_back/constants.dart';

import 'main_screen_notifier.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainScreenNotifierProvider);
    return Scaffold(
      body: state.when(
          data: (s) {
            return Row(
              children: [
                SizedBox(
                  width: minSize.width - 16,
                  child: Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: s.isCameraAvailable
                              ? () {
                                  ref
                                      .read(mainScreenNotifierProvider.notifier)
                                      .toggle();
                                }
                              : null,
                          child: s.isMaximized ? Text("收起") : Text("展开")),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: s.isCameraAvailable
                              ? () async {
                                  ref
                                      .read(mainScreenNotifierProvider.notifier)
                                      .initCamera();
                                }
                              : null,
                          child: Text("唤起摄像头"))
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  width: s.isMaximized ? maxSize.width - 400 : 0,
                  child: Column(
                    spacing: 10,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: backgroundDecoration,
                                    child:
                                        s.isCameraReady && s.isCameraAvailable
                                            ? CameraPlatform.instance
                                                .buildPreview(s.cameraId)
                                            : null,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: backgroundDecoration,
                                  )),
                            ],
                          )),
                      Expanded(
                          flex: 1,
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: backgroundDecoration,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: backgroundDecoration,
                                  )),
                            ],
                          ))
                    ],
                  ),
                )
              ],
            );
          },
          error: (_, e) {
            return Center(
              child: Text(e.toString()),
            );
          },
          loading: () => Center(
                child: AnimatedEightTrigrams(
                  size: 200,
                ),
              )),
    );
  }
}
