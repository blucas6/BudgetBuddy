import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/components/tags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyPieChart extends StatefulWidget {
  // this object displays the users transactions by month

  final Datadistributer datadistributer;  // connection to pipeline
  final double sliceSize = 100;
  final double sliceExpanded = 110;
  final double radiusSize = 30;
  final int animationTime = 750;
  final String unnamedCategory = 'Unnamed';

  const MonthlyPieChart({super.key, required this.datadistributer});

  @override   
  State<MonthlyPieChart> createState() => MonthlyPieChartState();
}

class MonthlyPieChartState extends State<MonthlyPieChart> {
  bool pieChartLoaded = false;
  List<TransactionObj> allTransactions = [];  // list of transaction objects  
  double totalMonthlySpending = 0;
  Map<String, dynamic> slicesMap = {};
  List<MaterialColor> colorsList = [
    Colors.blue, Colors.amber, Colors.cyan, Colors.deepOrange,
    Colors.green, Colors.indigo, Colors.lime, Colors.deepPurple,
    Colors.yellow, Colors.purple, Colors.red, Colors.teal, Colors.pink, 
    Colors.lightGreen
    ];
  int? touchedIndex;

  @override
  void initState() {
    loadSlices(null, null);
    super.initState();
  }

  void loadSlices(String? year, String? month) async {
    debugPrint("Reloading slices for pie chart");
    slicesMap = {};
    totalMonthlySpending = 0;
    // get all transactions available
    allTransactions = await widget.datadistributer.allTransactions;
    // go through transactions to set up the map
    for (TransactionObj trans in allTransactions) {
      String possibleTag = trans.tags.isNotEmpty ? trans.tags[trans.tags.length-1] : '';
      // only use transaction IF
      //  the transaction matches the filtered year
      //  the year filter is blank
      //  the transaction matches the filtered month
      //  the month filter blank
      //  the transaction is not HIDDEN or INCOME
      if ((year == null || trans.year == year) && (month == null || trans.month == month) &&
          Tags().isTransactionSpending(trans)) {
        // skip transactions that are not spending
        if (trans.cost > 0) continue;
        // check if category is present in map
        if (trans.category != null && trans.category != '') {
          if (slicesMap.containsKey(trans.category)) {
            slicesMap[trans.category!] += trans.cost;
          } else {
            slicesMap[trans.category!] = trans.cost;
          }
        } else if (possibleTag != '') {
          if (slicesMap.containsKey(possibleTag)) {
            slicesMap[possibleTag] += trans.cost;
          } else {
            slicesMap[possibleTag] = trans.cost;
          }
        } else if (slicesMap.containsKey(widget.unnamedCategory)) {
          slicesMap[widget.unnamedCategory] += trans.cost;
        } else {
          slicesMap[widget.unnamedCategory] = trans.cost;
        }
        // add to total spending
        totalMonthlySpending += trans.cost;
      }
    }
    // if there are slices, the piechart is loaded
    if (slicesMap.isNotEmpty) pieChartLoaded = true;
    // print(totalMonthlySpending);
    // print(slicesMap);
    setState(() {});
  }

  List<PieChartSectionData> getPieChartSections() {
    int sectionCounter = 0;
    List<PieChartSectionData> sections = [];
    if ((-1*totalMonthlySpending) > 0) {
      slicesMap.forEach((category, cost) {
        sections.add(PieChartSectionData(
          color: colorsList[sectionCounter],
          value: ((-1*cost)/(-1*totalMonthlySpending))*100,
          radius: touchedIndex == sectionCounter ? widget.sliceExpanded : widget.sliceSize,
          title: '\$${(-1*cost).toStringAsFixed(2)}',
          titleStyle: touchedIndex == sectionCounter ? 
          TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)
           : TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
        ));
        sectionCounter++;
      }); 
    } else {
      sections.add(PieChartSectionData(
        color: Colors.grey,
        value: 100,
        radius: widget.sliceSize,
        title: 'No Data',
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
      ));
    }
    return sections;
  }

  List<Padding> getLegend() {
    List<Padding> mylegend = [];
    int sectionCounter = 0;
    if ((-1*totalMonthlySpending) > 0) {
      slicesMap.forEach((category, cost) {
        mylegend.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                color: colorsList[sectionCounter],
              ),
              SizedBox(width: 2),
              Text(category)
            ]
          ),
        ));
        sectionCounter++;
      });
    }
    return mylegend;
  }

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> mysections = getPieChartSections();
    return Container(
      height: 400,
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40),
          Text(
            'Monthly Spending Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: PieChart(
                  swapAnimationDuration: Duration(milliseconds: widget.animationTime),
                  swapAnimationCurve: Curves.easeInOutQuint,
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        int? beforeState = touchedIndex;
                        if (event.isInterestedForInteractions && pieTouchResponse != null) {
                          touchedIndex = pieTouchResponse.touchedSection?.touchedSectionIndex;
                        } else {
                          touchedIndex = null;
                        }
                        if (beforeState != touchedIndex) setState(() {});
                      }
                    ),
                    sections: mysections,
                    centerSpaceRadius: widget.radiusSize, // Center space size
                    sectionsSpace: 2, // Space between sections
                  ),
                )
              ),
              SizedBox(width: 50),
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: getLegend())
                ],
              )
            ]
          )
        ]
      )
    );
  }
}
