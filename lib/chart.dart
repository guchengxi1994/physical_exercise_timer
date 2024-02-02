// ignore_for_file: depend_on_referenced_packages

import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:physical_exercise_timer/isar/database.dart';
import 'isar/record.dart' as d;
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key});

  @override
  State<ChartView> createState() => _ChartState();
}

class _ChartState extends State<ChartView> {
  final IsarDatabase database = IsarDatabase();

  Widget child0 = Container();
  Widget child1 = Container();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  final r = await myShowCustomDateRangePicker(
                    context,
                    dismissible: true,
                    minimumDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    maximumDate: DateTime.now().add(const Duration(days: 30)),
                    endDate: DateTime.now().add(const Duration(days: 1)),
                    startDate: DateTime.now().subtract(const Duration(days: 1)),
                    backgroundColor: Colors.white,
                    primaryColor: Colors.green,
                  );
                  if (r.$1 != null && r.$2 != null) {
                    List<d.Record> records = await database.getCertainTime(
                        r.$1!.millisecondsSinceEpoch,
                        r.$2!.millisecondsSinceEpoch);

                    List<d.Record> breaks = records
                        .where((element) =>
                            element.recordType == d.RecordType.Break)
                        .toList();

                    setState(() {
                      child1 = _buildAll(records);
                      child0 = _buildBreak(breaks);
                    });
                  }
                },
                child: const Icon(Icons.date_range),
              ),
              const Spacer(),
            ],
          ),
          child1,
          const SizedBox(
            height: 50,
          ),
          child0,
        ],
      ),
    );
  }

  double height = 300;
  double width = 300;

  Widget _buildAll(List<d.Record> records) {
    final groups = database.getGroups(records);

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      width: width,
      height: height,
      child: BarChart(BarChartData(
          titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) => SideTitleWidget(
                axisSide: AxisSide.bottom,
                child: SizedBox(
                  height: 40,
                  child: Text(DateFormat(DateFormat.HOUR24_MINUTE).format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (groups[value.toInt()].$1 ??
                                  groups[value.toInt()].$2)!
                              .createAt))),
                )),
          ))),
          barGroups: groups
              .mapIndexed((index, element) => makeGroupData(
                  index,
                  double.parse(
                      ((element.$1?.duration ?? 0) / 60).toStringAsFixed(2)),
                  double.parse(
                      ((element.$2?.duration ?? 0) / 60).toStringAsFixed(2))))
              .toList())),
    );
  }

  Widget _buildBreak(List<d.Record> records) {
    return SizedBox(
      width: width,
      height: height,
      child: BarChart(BarChartData(
          barGroups: records
              .mapIndexed((index, element) => makeSingleData(index,
                  double.parse((element.duration / 60).toStringAsFixed(2))))
              .toList())),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2,
      {double max = 120}) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: max < y1 ? max : y1,
          color: Colors.red,
          width: 7,
        ),
        BarChartRodData(
          toY: max < y2 ? max : y2,
          color: Colors.green,
          width: 7,
        ),
      ],
    );
  }

  BarChartGroupData makeSingleData(int x, double y1, {double max = 120}) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: max < y1 ? max : y1,
          color: Colors.green,
          width: 7,
        ),
      ],
    );
  }
}

Future<(DateTime?, DateTime?)> myShowCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  required Color backgroundColor,
  required Color primaryColor,
  String? fontFamily,
}) async {
  /// Request focus to take it away from any input field that might be in focus
  FocusScope.of(context).requestFocus(FocusNode());

  /// Show the CustomDateRangePicker dialog box
  final (DateTime?, DateTime?) r = await showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => CustomDateRangePicker(
      barrierDismissible: true,
      backgroundColor: backgroundColor,
      primaryColor: primaryColor,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      initialStartDate: startDate,
      initialEndDate: endDate,
    ),
  );

  return r;
}
