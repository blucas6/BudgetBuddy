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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Monthly Spending',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Placeholder for actual pie chart
          const Text(
            'Pie chart goes here',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
