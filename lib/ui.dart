import 'dart:async';

import 'package:auto_lock_windows/auto_lock_windows.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_button/group_button.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:physical_exercise_timer/chart.dart';
import 'package:physical_exercise_timer/constants.dart';
import 'package:physical_exercise_timer/isar/database.dart';
import 'package:physical_exercise_timer/isar/record.dart';
import 'package:physical_exercise_timer/notifier.dart';
import 'package:physical_exercise_timer/state.dart';
import 'package:physical_exercise_timer/utils.dart';
import 'package:window_manager/window_manager.dart';

class UI extends ConsumerStatefulWidget {
  const UI({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UIState();
}

class _UIState extends ConsumerState<UI> {
  final _autoLockWindowsPlugin = AutoLockWindows();
  late final controller = GroupButtonController(
      selectedIndex: ref.watch(appProvider).notificationType.id);

  final NotifierController notifierController = NotifierController();
  final PageController pageController = PageController(initialPage: 0);

  late Icon icon = const Icon(
    Icons.image,
    color: color,
  );

  static const Color color = Colors.black54;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: WindowCaption(
            brightness: Brightness.light,
            backgroundColor: Colors.lightBlue,
            title: Row(
              children: [
                const SizedBox(
                  width: 150,
                ),
                InkWell(
                  onTap: () {
                    if (pageController.page == 0) {
                      pageController.animateToPage(1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                      icon = const Icon(
                        Icons.list,
                        color: color,
                      );
                    } else {
                      pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear);
                      icon = const Icon(
                        Icons.image,
                        color: color,
                      );
                    }
                    setState(() {});
                  },
                  child: icon,
                )
              ],
            ),
          )),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          children: [_buildMain(state), const ChartView()],
        ),
      ),
    );
  }

  Widget _buildMain(AppState state) {
    return Column(
      children: [
        _wrapper(
            "设置等待时间",
            SizedBox(
              child: Row(
                children: [
                  Text("${state.duration ~/ 60} min"),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      var resultingDuration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(minutes: 30),
                      );
                      if (resultingDuration != null) {
                        ref
                            .read(appProvider.notifier)
                            .changeDuration(resultingDuration.inSeconds);
                      }
                    },
                    child: const Icon(Icons.update),
                  )
                ],
              ),
            )),
        const SizedBox(
          height: 40,
        ),
        _wrapper(
            "设置活动时间",
            SizedBox(
              child: Row(
                children: [
                  Text("${state.execDuration ~/ 60} min"),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      var resultingDuration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(minutes: 5),
                      );
                      if (resultingDuration != null) {
                        ref
                            .read(appProvider.notifier)
                            .changeExecDuration(resultingDuration.inSeconds);
                      }
                    },
                    child: const Icon(Icons.update),
                  )
                ],
              ),
            )),
        const SizedBox(
          height: 40,
        ),
        Row(
          children: [
            const Text("设置提示类型"),
            Expanded(
                child: SizedBox(
              child: GroupButton<NotificationType>(
                controller: controller,
                isRadio: true,
                onSelected: (index, isSelected, b) {
                  ref
                      .read(appProvider.notifier)
                      .changeType(NotificationType.fromType(index.id));
                },
                buttons: NotificationType.values,
              ),
            ))
          ],
        ),
        const SizedBox(
          height: 40,
        ),
        // const SizedBox(
        //   height: 20,
        // ),
        _buildCountDownWidget(state)
      ],
    );
  }

  _wrapper(String title, Widget child) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(title),
          ),
          Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ))
        ],
      ),
    );
  }

  late int duration = 0;
  bool started = false;
  String notification = "";

  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = _myStream.listen((event) {});
  }

  @override
  void dispose() {
    try {
      _sub.cancel();
    } catch (_) {}
    pageController.dispose();
    super.dispose();
  }

  late final Stream _myStream =
      Stream.periodic(const Duration(seconds: 1), (int count) async {
    final state = ref.watch(appProvider);
    if (started) {
      duration += 1;

      if (duration >= state.duration) {
        await database.record(RecordType.Break).then((value) {
          switch (state.notificationType) {
            case NotificationType.Lock:
              _autoLockWindowsPlugin.lockScreen();
            case NotificationType.Notification:
              notifierController.newNotification("Get up",
                  "You should take a break", "You should take a break");
            case NotificationType.ToastInApp:
              ToastUtils.message(context,
                  title:
                      "you should take a ${state.execDuration ~/ 60} min break");
            default:
              _autoLockWindowsPlugin.lockScreen();
          }
        });
      } else if (duration == (0.75 * (state.duration)).ceil()) {
        windowManager.focus();
        _autoLockWindowsPlugin.playSound();
      }

      setState(() {
        if (duration >= state.duration) {
          started = false;
          duration = 0;
        }
      });
    }
  });

  Widget _buildCountDownWidget(AppState state) {
    return SizedBox(
      width: windowWidth,
      child: Center(
        child: CircularPercentIndicator(
            radius: 70,
            lineWidth: 5.0,
            percent: (state.duration - duration) / state.duration,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Remaining ${state.duration - duration} Secs",
                    style: const TextStyle(color: Color(0xFF535355))),
                ElevatedButton(
                    onPressed: () async {
                      if (!started) {
                        await database.record(RecordType.Break);
                        setState(() {
                          started = true;
                        });
                      } else {
                        await database.record(RecordType.Work);
                        setState(() {
                          duration = 0;
                        });
                      }
                    },
                    child:
                        !started ? const Text("Start") : const Text("Resume"))
              ],
            ),
            linearGradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[Color(0xFF1AB600), Color(0xFF6DD400)]),
            rotateLinearGradient: true,
            circularStrokeCap: CircularStrokeCap.round),
      ),
    );
  }

  final IsarDatabase database = IsarDatabase();
}
