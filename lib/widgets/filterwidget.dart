

import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  // this callback triggers the main app to reload all widgets
  final void Function(String? year, String? month) newFilterTrigger;
  final Datadistributer datadistributer;
  const FilterWidget({super.key, required this.newFilterTrigger, required this.datadistributer});

  @override  
  State<FilterWidget> createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> {
  String? currentMonth;
  String? currentYear;
  // dataRange holds the date ranges available per what is in the database
  // the structure is: { <year1> : [month1, month2, ...],
  //                     <year2> : [month4, month5, ..] }
  Map<String, dynamic> dataRange = {};

  @override  
  void initState() {
    super.initState();
    loadData();
  }

  // reloads the widgets data and rebuilds it
  void loadData() async {
    currentMonth = null;
    currentYear = null;
    dataRange = await widget.datadistributer.getTotalDateRange();
    setState(() {});
  }

  // creates the dropdown for the months
  List<DropdownMenuItem> getMonthChoices() {
    List<DropdownMenuItem> choices = [];
    if (currentYear != null && dataRange.containsKey(currentYear)) {
      for (String month in dataRange[currentYear]) {
        choices.add(
          DropdownMenuItem(
            value:month,
            child: Text(month)
          )
        );
      }
    }
    return choices;
  }

  // creates the dropdown for the year
  List<DropdownMenuItem> getYearChoices() {
    List<DropdownMenuItem> choices = [];
    dataRange.forEach((year, months) {
      choices.add(
        DropdownMenuItem(
          value: year,
          child: Text(year)
        )
      );
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton(
              value: currentYear,
              hint: const Text('Select a year'),
              items: getYearChoices(), 
              onChanged: (dynamic newValue) {
                currentYear = newValue;
                currentMonth = null;
                widget.newFilterTrigger(currentYear, currentMonth);
                setState(() {});
              }
            ),
            DropdownButton(
              value: currentMonth,
              hint: const Text('Select a month'),
              items: getMonthChoices(), 
              onChanged: (dynamic newValue) {
                currentMonth = newValue;
                widget.newFilterTrigger(currentYear, currentMonth);
                setState(() {});
              }
            )
          ]
        ),
      );
  }
}