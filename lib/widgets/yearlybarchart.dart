import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/components/tags.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class YearlyBarChart extends StatefulWidget {
  const YearlyBarChart({super.key, required this.datadistributer});

  final Datadistributer datadistributer;
  final double widthOfColumn = 600;
  final int animationTime = 750;

  @override
  State<YearlyBarChart> createState() => YearlyBarChartState();
}

class YearlyBarChartState extends State<YearlyBarChart> {

List<TransactionObj> allTransactions = [];
Map<String,dynamic> allBars = {};
String? currentMonth;
MaterialColor currentMonthColor = Colors.amber;
MaterialColor monthColor = Colors.blue;
double barWidth = 25;
double barRadius = 4;
double maxSpent = 0;

@override
void initState() {
  super.initState();
  loadData(null,null);
}

void loadData(String? year, String? month) async {
  allBars = {};
  maxSpent = 0;
  currentMonth = month;
  debugPrint("Reloading data for yearly bar chart $year $month");
  allTransactions = await widget.datadistributer.allTransactions;
  if (year == null && month == null && allTransactions.isNotEmpty) {
    year = allTransactions[0].year;
    currentMonth = allTransactions[0].month;
  }
  for (TransactionObj trans in allTransactions) {
    // INCOME/HIDDEN money not counted in spending
    if (trans.year == year && Tags().isTransactionSpending(trans)) {
      trans.cost ??= 0;
      // refunds are counted as lowering total spending (does not need to be > 0)
      if (allBars.containsKey(trans.month)) {
        allBars[trans.month] += (-1*trans.cost!);
      } else {
        allBars[trans.month] = (-1*trans.cost!);
      }
    }
  }
  // find the largest bar and add a buffer
  allBars.forEach((key, value) {
    if (value > maxSpent) maxSpent = value;
    if (value < 0) allBars[key] = 0.0;
  });
  maxSpent += (maxSpent*.03);
  debugPrint("Bar Chart data:");
  print(allBars);
  setState(() {});
}


BarChart getBarChart() {
  List<BarChartGroupData> myBars = [];
  int index = 0;

  allBars.forEach((month, cost) {
    MaterialColor thisColor = currentMonth != null ? (month == currentMonth ? currentMonthColor : monthColor) : monthColor;
    myBars.add(
      BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: cost,
            color: thisColor,
            width: barWidth,
            borderRadius: BorderRadius.circular(barRadius)
          )
        ]
      )
    );
    index++;
  });

  return BarChart(
    swapAnimationDuration: Duration(milliseconds: widget.animationTime),
    swapAnimationCurve: Curves.easeInOutQuint,
    BarChartData(
      maxY: maxSpent,
      minY: 0,
      barGroups: myBars,
      borderData: FlBorderData(show: true),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double index, _) {
              return Text(allBars.keys.toList()[index.toInt()], style: TextStyle(fontSize: 12));
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false
          )
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false
          )
        )
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String category = allBars.keys.toList()[groupIndex.toInt()];
            return BarTooltipItem(
              '$category\n\$${rod.toY.toInt()}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    ),
  );      
}

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
              'Month-by-Month View',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ),
          // Bar Chart Section
          Center(
            child: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: widget.widthOfColumn,
                minHeight: 50,
                maxHeight: 150
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 2, top: 15, right: 15, left: 0),
                child: getBarChart()
              )
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}