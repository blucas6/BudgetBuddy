import 'package:budgetbuddy/services/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({super.key});
  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  List<TransactionObj> currentTransactions = [];   // list of transaction objects
  List<List<String>> currentTransactionStrings = [];  // list of transaction objects as strings for display
  List<bool?> columnSorts = List.filled(TransactionObj().getProperties().keys.length, null);   // fill null for however many columns we have
  Map<int, TableColumnWidth> columnSizes = {};  // keep track of sizing for columns

  // load transactions on startup
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    // TODO: load transactions from database
    currentTransactions.add(TransactionObj(id:0, dates:'2010-10-16', cardn:999, content:'purchase', category: '', cost:12.00));
    currentTransactions.add(TransactionObj(id:1, dates:'2010-10-12', cardn:200, content:'fun', category: '', cost:120.00));
    currentTransactions.add(TransactionObj(id:2, dates:'2010-11-13', cardn:999, content:'going out', category: '', cost:2.00));
    currentTransactions.add(TransactionObj(id:3, dates:'2011-10-14', cardn:999, content:'this is a really long description', category: 'and a category', cost:1000.00));
    currentTransactions.add(TransactionObj(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    
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
    int cindex = 0;   // keep track of index for sort function

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
        if (cindex == 0) {
          decoration = BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
              color: headerColor
          );
        // topright rounded box
        } else if(cindex == props.length-1) {
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
                getColumnIcon(cindex)  // dynamically generate icon based on sorting state (icon contains sort function)
              ]
            ),
          )
        );
        // add index and respective size
        columnSizes.addEntries([MapEntry(cindex, FixedColumnWidth(cwidth))]);
        cindex++;
      }
    });
    return myHeaders;
  }

  Table createDataTable() {
    List<TableRow> myRows = [];   // holds all rows for the table
    Map<String, dynamic> displayProperties = TransactionObj.defaultTransaction().getDisplayProperties();
    // loop through the transactions to create the cells and rows
    int rowcount = 0;   // keep track of rows for coloring
    for (List<String> row in currentTransactionStrings) {
      List<TableCell> myCells = [];
      int cellcount = 0;  // keep track of cells to determine what to display
      // loop through properties and only display cells that need to be displayed
      displayProperties.forEach((key, isDisplay) {
        if (isDisplay) {
          String cell = row[cellcount];
          myCells.add(
            TableCell(
              child: Container(
                height: 30,
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                color: rowcount % 2 != 0 ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 201, 240, 255),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(cell)),
              ),
            )
          );
        }
        cellcount++;
      });
      // add finished row
      myRows.add(
        TableRow(
          children: myCells,
        )
      );
      rowcount++;
    }
    return Table(
        border: TableBorder.symmetric(),
        columnWidths: columnSizes,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: myRows,
      );
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
            child: createDataTable()
          ),
        )
      ]),
    );
  }
}
