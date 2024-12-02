import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:budgetbuddy/widgets/editmenuwidget.dart';
import 'package:budgetbuddy/components/tags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TransactionWidget extends StatefulWidget {
  // This object displays the transaction data table

  final Datadistributer datadistributer;  // access to pipeline
  final double maxTransactionWidgetHeight = 450; // controls how long the widget is
  final void Function() newDataTrigger;
  const TransactionWidget({super.key, required this.datadistributer, required this.newDataTrigger});

  @override
  State<TransactionWidget> createState() => TransactionWidgetState();
}

class TransactionWidgetState extends State<TransactionWidget> {
  List<TransactionObj> allTransactions = [];              // list of transaction objects
  List<TransactionObj> currentFilteredTransactions = [];  // sorts them based on existing filters
  List<List<String>> currentTransactionStrings = [];      // list of transaction objects as strings for display
  String? activeYearFilter;
  String? activeMonthFilter;
  Map<int, TableColumnWidth> columnSizes = {};            // keep track of sizing for columns
  List<List<bool>> rowHovers = [];                        // keep track of which rows are being hovered

  // used to keep track of which columns are sorted
  //fill null for however many columns we have
  List<bool?> columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);
    
  // load transactions on startup
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  // reload the data
  void loadTransactions() async {
    debugPrint("Reloading transaction widget");
    // get the transactions from the datadistributer
    allTransactions = await widget.datadistributer.allTransactions;
    currentFilteredTransactions = allTransactions;
    // apply filters if there are any
    if (activeMonthFilter != null && activeYearFilter != null) {
      applyFilters(activeYearFilter!, activeMonthFilter!);
    }
    // turn data to strings to display
    currentTransactionStrings = transactionsToStrings(currentFilteredTransactions);
    setState(() {});
  }

  // load the filtered transaction object with data
  void applyFilters(String year, String month) {
    activeMonthFilter = month;
    activeYearFilter = year;
    debugPrint("Applying filter $year $month");
    currentFilteredTransactions = [];
    // go through the transaction object
    for (TransactionObj trans in allTransactions) {
      if (trans.year == year && trans.month == month) {
        // add to the list if a transaction is within the range
        currentFilteredTransactions.add(trans);
      }
    }
    // reload the current transaction strings for display
    currentTransactionStrings = transactionsToStrings(currentFilteredTransactions);
    setState(() {});
  }

  // create a the headers for the data table
  // the headers depend on the transaction obj interface
  // does not depend on any loaded data
  List<Container> createDataTableHeaders() {
    List<Container> myHeaders = [];   // holds header objects

    // create default transaction for display structure (in case no data is loaded)
    // use the first transaction for layout
    Map<String, dynamic> props = TransactionObj.defaultTransaction().getProperties();
    Map<String, dynamic> displayProps = TransactionObj.defaultTransaction().getDisplayProperties();
    int tableColumnIndex = 0;   // keep track of index for column sizing
    int totalColumnsDisplayed = 0;
    displayProps.forEach((column, toDisplay) {
      if (toDisplay) totalColumnsDisplayed++;
    });
    int sortIndex = 0;  // keep track of index for sorting

    // loop through the transaction to get the columns
    props.forEach((header, value) {
      // check that column should be displayed, use displayProperties
      if (displayProps[header]) {
        double cwidth = 150;  // default column width
        BoxDecoration decoration;
        Color headerColor = Colors.blueAccent;
        // change column width for small headers
        if(header.length < 3) {
          cwidth = 80;
        } else if (header.length < 7) {
          cwidth = 90;
        }
        // topleft rounded box
        if (tableColumnIndex == 0) {
          decoration = BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
              color: headerColor
          );
        // topright rounded box
        } else if(tableColumnIndex == totalColumnsDisplayed-1) {
          decoration = BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
              color: headerColor
          );
        // middle no rounding
        } else {
          decoration = BoxDecoration(
            color: headerColor
          );
        }
        // add container to list of headers
        myHeaders.add(        
          Container(
            decoration: decoration,
            width: cwidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(header),
                getColumnIcon(sortIndex)  // dynamically generate icon based on sorting state (icon contains sort function)
              ]
            ),
          )
        );
        // add index and respective size
        columnSizes.addEntries([MapEntry(tableColumnIndex, FixedColumnWidth(cwidth))]);
        tableColumnIndex++; // increment columns when done building
      }
      sortIndex++;  // increment sort index regardless if column is displayed or not
    });
    return myHeaders;
  }

  // create the data rows for the data table
  // the data rows depend on the current transactions strings that are loaded
  Table createDataTable(BuildContext context) {
    List<TableRow> myRows = [];   // holds all rows for the table
    Map<String, dynamic> displayProperties = TransactionObj.defaultTransaction().getDisplayProperties();
    // loop through the transactions to create the cells and rows
    for (int rowc=0; rowc<currentTransactionStrings.length; rowc++) {
      // for hidden transactions
      bool textIsHidden = false;
      String taglist = currentTransactionStrings[rowc][currentTransactionStrings[0].length-1];
      if (taglist.contains(Tags().HIDDEN)) textIsHidden = true;
      // for shading on hover
      if (rowHovers.length == rowc) {
        rowHovers.add(List.filled(TransactionObj().getProperties().keys.length, false));
      }
      List<TableCell> myCells = [];
      // loop through properties and only display cells that need to be displayed
      List<MapEntry<String,dynamic>> entries = displayProperties.entries.toList();
      for (int colc=0; colc<entries.length; colc++) {
        if (entries[colc].value as bool) {
          String cellText = currentTransactionStrings[rowc][colc];
          myCells.add(
            TableCell(
              child: MouseRegion(
                onEnter: (_) => onHover(rowc, colc, true),
                onExit: (_) => onHover(rowc, colc, false),
                child: GestureDetector(
                  onTap: () {
                    showEditMenu(context, rowc);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 30,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    color: rowc % 2 != 0 ? (rowHovers[rowc][colc] ? Color.fromARGB(255, 233, 233, 233) : Color.fromARGB(255, 255, 255, 255)) : (rowHovers[rowc][colc] ? Color.fromARGB(255, 193, 222, 233) : Color.fromARGB(255, 201, 240, 255)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(cellText, 
                        style: TextStyle(fontStyle: textIsHidden ? FontStyle.italic : FontStyle.normal,
                                          color: textIsHidden ? Colors.grey : Colors.black)
                      )
                    ),
                  ),
                ),
              ),
            )
          );
        }
      }
      // add finished row
      myRows.add(
        TableRow(
          children: myCells,
        )
      );
    }
    return Table(
        border: TableBorder.symmetric(),
        columnWidths: columnSizes,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: myRows,
      );
  }

  // set the rowHovers object to dictate which rows are being hovered
  void onHover(int rc, int cc, bool isHover) {
    setState(() {
      for(int i=0; i<rowHovers[rc].length; i++) {
        rowHovers[rc][i] = isHover;
      }
    });
  }

  // trigger a sorting of the transactions
  void sortMe(int cindex) {
    if (currentFilteredTransactions.isEmpty) {
      return;
    }
    // sort transaction data depending on the column index
    // get transactions as a map array
    List<Map<String,dynamic>> sortedTransactionMap = [];
    for (TransactionObj ctr in currentFilteredTransactions) {
      sortedTransactionMap.add(ctr.getProperties());
    }
    // find the column of interest as a key
    String ourkey = currentFilteredTransactions[0].getProperties().keys.toList()[cindex];
    // do not sort if the column holds lists of values
    if (sortedTransactionMap[0][ourkey] is List) {
      return;
    }
    // set all columns besides the one of interest to null
    for (int i=0; i<columnSorts.length; i++) {
      columnSorts[i] = cindex != i ? null : columnSorts[i];
    }
    if (columnSorts[cindex] == null) {
      // turning to true means to sort from highest to lowest
      columnSorts[cindex] = true;
      sortedTransactionMap.sort((a,b) =>
        b[ourkey].compareTo(a[ourkey])
      );
    } else if (columnSorts[cindex] == true) {
      // turning to false means from lowest to highest
      columnSorts[cindex] = false;
      sortedTransactionMap.sort((a, b) => 
        a[ourkey].compareTo(b[ourkey])
      );
    } else {
      // back to else returns the order to normal
      columnSorts[cindex] = null;
    }

    // reset transaction strings so the table is regenerated with sorted data
    setState(() {
      currentTransactionStrings = transactionsToStrings(sortedTransactionMap);
    });
  }

  // convert a given transaction object to a list of strings 
  // the data table will be created from this list of strings
  List<List<String>> transactionsToStrings(dynamic myTransactions) {
    // Pass either a List<Transaction> or a List<Map<String,dynamic>>
    List<List<String>> transactionStrings = [];
    for (dynamic trans in myTransactions) {
      List<String> row = [];  // resulting row
      Map<String, dynamic> transrow = {};   // row to parse

      // if using a transactionObj, turn it into a map first
      if (trans is TransactionObj) {
        transrow = trans.getProperties();
      } else {
        // if using a List<Map<String,dynamic>> just assign the iterator
        transrow = trans;
      }

      // parse the row
      transrow.forEach((header, value) {
        String val = '';
        if (value is String) {
          // string values don't require any parsing
          val = value;
        } else if (value is DateTime) {
          if (value == DateTime.parse('1980-01-01')) {
            val = '';   // don't display default date
          } else {
            val = DateFormat('yyyy-MM-dd').format(value); // parse date
          }
        } else if (value is List || value is List<String>) {
          val = value.join(" ");
        } else if (value == null) {
          val = ''; // don't display null params
        } else {
          val = value.toString();
        }
        row.add(val);
      });
      transactionStrings.add(row);
    }
    return transactionStrings;
  }

  // returns an icon button that triggers the sort function
  IconButton getColumnIcon(int cindex) {
    Transform myIcon;
    if (columnSorts[cindex] == null) {
      // unsorted column
      myIcon = Transform.rotate(
        angle: 0,
        child: const Icon(Icons.arrow_left_rounded)
      );
    } else if (columnSorts[cindex] == false) {
      // column sorted lowest to highest
      myIcon = Transform.rotate(
        angle: 0,
        child: const Icon(Icons.arrow_drop_down_rounded)
      );
    } else {
      // column sorted highest to lowest
      myIcon = Transform.rotate(
        angle: 180 *math.pi / 180,
        child: const Icon(Icons.arrow_drop_down_rounded)
      );
    }
    return IconButton(onPressed: () {sortMe(cindex);}, icon: myIcon, padding: EdgeInsets.zero);
  }

  void showEditMenu(BuildContext context, int index) async {
    String? newTag = await showDialog<String?>(context: context, builder: (BuildContext context) {
      return EditMenuWidget();
    });
    // reset sort icons since the transactions will be reloaded unsorted
    columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);
    // find the ID of the transaction clicked on
    int id = int.parse(currentTransactionStrings[index][0]);
    // go through all transactions to find the correct ID
    for (int i=0; i<currentFilteredTransactions.length; i++) {
      if (currentFilteredTransactions[i].id == id) {
        List<String> currentTags = currentFilteredTransactions[i].tags;
        if (newTag != null) {
          if (newTag == '_delete_') {
            currentTags = [];
          } else {
            currentTags.add(newTag);
          }
          // update the transaction through the pipeline
          await widget.datadistributer.updateData(id, 'Tags', currentTags.join(';'));
          // reload after user adds or removes a tag
          // the pipeline should already have the data necessary
          // with only the changed value updated
          // reload all widgets
          widget.newDataTrigger();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: createDataTableHeaders(),
        ),
        Container(
          constraints: BoxConstraints(
            minWidth: 500,
            minHeight: 200,
            maxHeight: widget.maxTransactionWidgetHeight),
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: createDataTable(context)
          ),
        )
      ]);
  }
}
