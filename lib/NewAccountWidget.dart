
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyGraphWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, title: 'Rent', color: Colors.blue),
          PieChartSectionData(value: 30, title: 'Food', color: Colors.red),
          PieChartSectionData(value: 20, title: 'Transport', color: Colors.green),
          PieChartSectionData(value: 10, title: 'Entertainment', color: Colors.yellow),
        ],
      ),
    );
  }
}
