import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'no_input_notifier.dart';

class NoInputChart extends ConsumerWidget {
  const NoInputChart({super.key});
  static const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
  static const Color color1 = Color(0xFF2196F3);
  static const Color color2 = Color(0xFFFFC300);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noInputNotifierProvider);

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: PieChart(PieChartData(sections: [
              PieChartSectionData(
                  color: color1,
                  value: state.restTime * 1.0,
                  // title: '40%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: shadows,
                  ),
                  badgeWidget: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(),
                        image: DecorationImage(
                            image: AssetImage("assets/rest.png"))),
                  )),
              PieChartSectionData(
                  color: color2,
                  value: state.workTime * 1.0,
                  // title: '40%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: shadows,
                  ),
                  badgeWidget: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        image: DecorationImage(
                            image: AssetImage("assets/work.png"))),
                  ))
            ])),
          ),
        ),
        Positioned(
            right: 20,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 10),
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                spacing: 4,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        color: color1,
                      ),
                      Text("Rest"),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        color: color2,
                      ),
                      Text("Work"),
                    ],
                  )
                ],
              ),
            )),
      ],
    );
  }
}
