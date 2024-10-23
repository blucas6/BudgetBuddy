import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';  

class MonthlyPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,  // Set the height of the chart
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.blue,  // Represents 50% (Needs)
              value: 50,
              title: '50%',
              radius: 50,
            ),
            PieChartSectionData(
              color: Colors.orange,  // Represents 30% (Wants)
              value: 30,
              title: '30%',
              radius: 50,
            ),
            PieChartSectionData(
              color: Colors.purple,  // Represents 20% (Savings)
              value: 20,
              title: '20%',
              radius: 50,
            ),
          ],
          sectionsSpace: 0,  
          centerSpaceRadius: 40, 
        ),
      ),
    );
  }
}

