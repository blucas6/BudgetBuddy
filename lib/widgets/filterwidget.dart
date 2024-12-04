import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  // This object displays the filtering to the user
  // Controls the data that the widgets show

  // this callback triggers the main app to reload all widgets
  final void Function(String? year, String? month) newFilterTrigger;
  final Datadistributer datadistributer; // connection to the data pipeline

  const FilterWidget({super.key, required this.newFilterTrigger, required this.datadistributer});

  @override
  State<FilterWidget> createState() => FilterWidgetState();
}

class FilterWidgetState extends State<FilterWidget> {
  String? currentMonth; // current month filter
  String? currentYear; // current year filter

  // dataRange holds the date ranges available per what is in the database
  // the structure is: { <year1> : [month1, month2, ...],
  //                     <year2> : [month4, month5, ..] }
  Map<String, dynamic> dataRange = {};

  @override
  void initState() {
    super.initState();
    loadData(null,null);
  }

  // reloads the widgets data and rebuilds it
  void loadData(String? yearSave, String? monthSave) async {
    debugPrint("Reloading filter widget");
    currentMonth = monthSave;
    currentYear = yearSave;
    dataRange = await widget.datadistributer.getTotalDateRange();
    setState(() {});
  }

  // creates the dropdown for the months
  List<DropdownMenuItem> getMonthChoices() {
    List<DropdownMenuItem> choices = [];
    // if the current year is loaded, go through the list of months available
    if (currentYear != null && dataRange.containsKey(currentYear)) {
      for (String month in dataRange[currentYear]) {
        choices.add(DropdownMenuItem(value: month, child: Text(month)));
      }
    }
    return choices;
  }

  // creates the dropdown for the year
  List<DropdownMenuItem> getYearChoices() {
    List<DropdownMenuItem> choices = [];
    // for each year in the map, create a drop down item
    dataRange.forEach((year, months) {
      choices.add(DropdownMenuItem(value: year, child: Text(year)));
    });
    return choices;
  }

  void clearFilters() {
    currentMonth = null;
    currentYear = null;
    widget.newFilterTrigger(null, null);
    setState(() {});
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
                // on new value set the month to null
                currentYear = newValue;
                currentMonth = null;
                // trigger the app to reload filters
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
                // trigger the app to reload filters
                widget.newFilterTrigger(currentYear, currentMonth);
                setState(() {});
              }
            ),
            IconButton(onPressed: () => clearFilters(), icon: const Icon(Icons.delete))
          ]
        ),
      );
  }
}
