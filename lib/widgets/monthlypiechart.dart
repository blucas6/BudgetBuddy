import 'package:flutter/material.dart';

class MonthlyPieChart extends StatefulWidget {
  const MonthlyPieChart({super.key});
  @override
  State<MonthlyPieChart> createState() => _MonthlyPieChartState();
}

class _MonthlyPieChartState extends State<MonthlyPieChart> {
  void loadMonth() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text('Monthly Spending'),
      ],
    );
  }
}
