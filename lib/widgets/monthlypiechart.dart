import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyAnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: Icon(Icons.arrow_back),
        actions: [Icon(Icons.notifications)],
        title: Text('Analysis'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\$7,783.00',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Expense',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '-\$1,187.40',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: 0.3, // 30% of expenses
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '30% of Your Expenses, Looks Good.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Income & Expenses',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.pie_chart),
                      SizedBox(width: 10),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 15,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const style = TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                );
                                switch (value.toInt()) {
                                  case 0:
                                    return Text('Jan', style: style);
                                  case 1:
                                    return Text('Feb', style: style);
                                  case 2:
                                    return Text('Mar', style: style);
                                  case 3:
                                    return Text('Apr', style: style);
                                  case 4:
                                    return Text('May', style: style);
                                  case 5:
                                    return Text('Jun', style: style);
                                  default:
                                    return Text('', style: style);
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: Colors.green)]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.green)]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.green)]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 13, color: Colors.green)]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 9, color: Colors.green)]),
                          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 7, color: Colors.green)]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\$47,200.00',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Expense',
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '\$35,510.20',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
