import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:save_my_back/app/chart_notifier.dart';
import 'package:save_my_back/src/rust/api/detector.dart';

class Chart extends ConsumerWidget {
  const Chart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.watch(chartNotifierProvider);

    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blueGrey.withAlpha(128),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: BarChart(
              mainBarData(ref
                  .read(chartNotifierProvider.notifier)
                  .stateToBarChartData()),
            ),
          ),
        ),
      ),
    );
  }

  BarChartData mainBarData(List<BarChartGroupData> data) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String state = getHint(
                state: getPoseStateByIndex(index: BigInt.from(groupIndex)));

            return BarTooltipItem(
              '$state\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY - 1).toString(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: data,
      gridData: const FlGridData(show: false),
    );
  }
}
