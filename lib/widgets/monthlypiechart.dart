import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyPieChart extends StatelessWidget {
  const MonthlyPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200, // Specify width to avoid infinite sizing issues
        height: 200, // Specify height to avoid infinite sizing issues
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.blue, // Represents necessary expenses
                value: 50,
                title: '50%',
                radius: 50,
                titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                color: Colors.orange, // Represents wants
                value: 30,
                title: '30%',
                radius: 50,
                titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                color: Colors.green, // Represents savings
                value: 20,
                title: '20%',
                radius: 50,
                titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
            centerSpaceRadius: 40, // Center space size
            sectionsSpace: 2, // Space between sections
          ),
        ),
      ),
    );
  }
}
