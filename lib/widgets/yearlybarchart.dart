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

List<TransactionObj> allTransactions = [];    // all transactions from the data distributer
// dictionary to generate barchart from
// { <month> : {'rent': x, 'spending': y}, ... }
Map<String,dynamic> allBars = {};
String? currentMonth;
Color currentMonthColor = const Color.fromARGB(255, 255, 193, 7);
Color currentMonthColorRent = const Color.fromARGB(255, 255, 202, 43);
Color currentMonthColorIncome = const Color.fromARGB(255, 194, 147, 8);
Color monthColor = const Color.fromARGB(255, 36, 152, 247);
Color monthColorRent = const Color.fromARGB(255, 103, 189, 250);
Color monthColorIncome = const Color.fromARGB(255, 14, 94, 151);
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
    // HIDDEN money not counted in spending
    if (trans.year == year && Tags().isValid(trans) && !Tags().isSavings(trans)) {
      // refunds are counted as lowering total spending (does not need to be > 0)
      if (allBars.containsKey(trans.month)) {
        if (Tags().isRent(trans)) {
          allBars[trans.month]['rent'] += trans.cost*-1;
        } else if (Tags().isIncome(trans)) { 
          allBars[trans.month]['income'] += trans.cost;
        } else {
          allBars[trans.month]['spending'] += trans.cost*-1;
        }
      } else if (Tags().isRent(trans)) {
        allBars[trans.month] = {'spending': 0.0, 'rent': trans.cost*-1, 'income': 0.0};
      } else if (Tags().isIncome(trans)) {
        allBars[trans.month] = {'spending': 0.0, 'rent': 0.0, 'income': trans.cost};
      } else if (Tags().isSavings(trans)) {
        allBars[trans.month] = {'spending': 0.0, 'rent': 0.0, 'income': 0.0, };      
      } else {
        allBars[trans.month] = {'spending': trans.cost*-1, 'rent': 0.0, 'income': 0.0};
      }
    }
  }
  print(allBars);
  // find the largest bar
  allBars.forEach((key, dict) {
    double value = dict['rent'] + dict['spending'];
    if (value > maxSpent) maxSpent = value;
    if (dict['income'] > maxSpent) maxSpent = dict['income'];
    // zero out negative spending
    if (value < 0) {
      allBars[key]['spending'] = 0.0;
      allBars[key]['rent'] = 0.0;
      allBars[key]['income'] = 0.0;
    }
  });
  maxSpent += (maxSpent*.03);   // top of the chart should be a bit higher than the highest bar
  debugPrint("Bar Chart data:");
  setState(() {});
}


BarChart getBarChart() {
  List<BarChartGroupData> myBars = [];
  int index = 0;

  List<String> monthsInOrder = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  for (String month in monthsInOrder) {
    if (allBars.containsKey(month)) {
      Color thisColor = currentMonth != null ? (month == currentMonth ? currentMonthColor : monthColor) : monthColor;
      Color thisColorRent = currentMonth != null ? (month == currentMonth ? currentMonthColorRent : monthColorRent) : monthColorRent;
      Color thisColorIncome = currentMonth != null ? (month == currentMonth ? currentMonthColorIncome : monthColorIncome) : monthColorIncome;
      double rent = allBars[month]['rent'];
      double spending = allBars[month]['spending'];
      double income = allBars[month]['income'];
      myBars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: spending,
              color: thisColor,
              width: barWidth,
              rodStackItems: [
                BarChartRodStackItem(0, rent, thisColorRent),
                BarChartRodStackItem(rent, spending, thisColor)
              ],
              borderRadius: BorderRadius.circular(barRadius)
            ),
            BarChartRodData(
              toY: income,
              color: thisColorIncome,
              width: barWidth,
              borderRadius: BorderRadius.circular(barRadius)
            )
          ]
        )
      );
      index++;
    }
  }

  return BarChart(
    duration: Duration(milliseconds: widget.animationTime),
    curve: Curves.easeInOutQuint,
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
            String rent = allBars[category]['rent'].toStringAsFixed(2);
            String spending = allBars[category]['spending'].toStringAsFixed(2);
            return BarTooltipItem(
              '$category\nSpending: \$$spending \nRent: \$$rent',
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