import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({Key? key}) : super(key: key);
  @override
  State<TransactionWidget> createState() => TransactionWidgetState();
}

class TransactionWidgetState extends State<TransactionWidget> {
  List<TransactionObj> currentTransactions = [];   // list of transaction objects
  List<List<String>> currentTransactionStrings = [];  // list of transaction objects as strings for display
  List<bool?> columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);   // fill null for however many columns we have
  Map<int, TableColumnWidth> columnSizes = {};  // keep track of sizing for columns
  List<List<bool>> rowHovers = [];
  String? _selectedTag;
  List<String> possibleTags = ['Hidden', 'Rent', 'Savings'];
  Datadistributer datadistributer = Datadistributer();
  // load transactions on startup
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() async {
    debugPrint("Reloading transaction widget");
    currentTransactions = await datadistributer.loadData();
    // turn data to strings to display
    currentTransactionStrings = transactionsToStrings(currentTransactions);
    setState(() {});
  }

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

  Table createDataTable(BuildContext context) {
    List<TableRow> myRows = [];   // holds all rows for the table
    Map<String, dynamic> displayProperties = TransactionObj.defaultTransaction().getDisplayProperties();
    // loop through the transactions to create the cells and rows
    for (int rowc=0; rowc<currentTransactionStrings.length; rowc++) {
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
                      child: Text(cellText)),
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

  void onHover(int rc, int cc, bool isHover) {
    setState(() {
      for(int i=0; i<rowHovers[rc].length; i++) {
        rowHovers[rc][i] = isHover;
      }
    });
  }

  void sortMe(int cindex) {
    // sort transaction data depending on the column index
    // get transactions as a map array
    List<Map<String,dynamic>> sortedTransactionMap = [];
    for (TransactionObj ctr in currentTransactions) {
      sortedTransactionMap.add(ctr.getProperties());
    }
    // find the column of interest as a key
    String ourkey = currentTransactions[0].getProperties().keys.toList()[cindex];
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

  IconButton getColumnIcon(int cindex) {
    // returns an icon button that triggers the sort function
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

  void showEditMenu(BuildContext context, int index) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add a tag"),
        content: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tag Transaction: "),
              DropdownButton(
                value: _selectedTag,
                hint: Text('Select a tag'),
                items: possibleTags.map((String tag) {
                  return DropdownMenuItem(value: tag, child: Text(tag));
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);
                    _selectedTag = newValue;
                    int id = int.parse(currentTransactionStrings[index][0]);
                    for (int i=0; i<currentTransactions.length; i++) {
                      if (currentTransactions[i].id == id) {
                        currentTransactions[i].tags = newValue;
                      }
                    }
                    currentTransactionStrings = transactionsToStrings(currentTransactions);
                    Navigator.of(context).pop();
                  });
                },
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);
                    int id = int.parse(currentTransactionStrings[index][0]);
                    for (int i=0; i<currentTransactions.length; i++) {
                      if (currentTransactions[i].id == id) {
                        currentTransactions[i].tags = '';
                      }
                    }
                    currentTransactionStrings = transactionsToStrings(currentTransactions);
                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(Icons.delete_outline)
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'))
          ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Row(
          children: createDataTableHeaders(),
        ),
        Container(
          alignment: Alignment.topLeft,
          constraints: BoxConstraints(
            maxHeight: 500
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: createDataTable(context)
          ),
        )
      ]),
    );
  }
}
