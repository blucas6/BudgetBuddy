import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Monthly Spending Analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Bar Chart Section
              Center(
                child: Container(
                  width: 300, // Increased width for the bar chart
                  height: 200, // Adjusted height
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: 60,
                      minY: 0,
                      barGroups: [
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 50,
                              color: Colors.blue,
                              width: 18, // Increased bar width
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 30,
                              color: Colors.orange,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: 20,
                              color: Colors.green,
                              width: 18,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (double value, _) => Text(
                              '${value.toInt()}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, _) {
                              switch (value.toInt()) {
                                case 1:
                                  return const Text('Needs', style: TextStyle(fontSize: 12));
                                case 2:
                                  return const Text('Wants', style: TextStyle(fontSize: 12));
                                case 3:
                                  return const Text('Savings', style: TextStyle(fontSize: 12));
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String category;
                            switch (group.x.toInt()) {
                              case 1:
                                category = 'Needs';
                                break;
                              case 2:
                                category = 'Wants';
                                break;
                              case 3:
                                category = 'Savings';
                                break;
                              default:
                                category = '';
                            }
                            return BarTooltipItem(
                              '$category\n${rod.toY.toInt()}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
  }
}