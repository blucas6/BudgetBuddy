
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class YearlyGraphWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: 500, color: Colors.blue),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: 400, color: Colors.red),
          ]),
        ],
      ),
    );
  }
}
