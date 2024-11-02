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
  List<Transaction> currentTransactions = [];   // list of transaction objects
  List<List<String>> currentTransactionStrings = [];  // list of transaction objects as strings for display
  List<bool?> columnSorts = List.filled(Transaction().getProperties().keys.length, null);   // fill null for however many columns we have
  Map<int, TableColumnWidth> columnSizes = {};

  // load transactions on startup
  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  void loadTransactions() {
    currentTransactions.add(Transaction(id:0, dates:'2010-10-16', cardn:999, content:'purchase', category: '', cost:12.00));
    currentTransactions.add(Transaction(id:1, dates:'2010-10-12', cardn:200, content:'fun', category: '', cost:120.00));
    currentTransactions.add(Transaction(id:2, dates:'2010-11-13', cardn:999, content:'going out', category: '', cost:2.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'this is a really long description', category: 'and a category', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    currentTransactions.add(Transaction(id:3, dates:'2011-10-14', cardn:999, content:'food', category: '', cost:1000.00));
    
    currentTransactionStrings = transactionsToStrings(currentTransactions); // turn to strings to display
    setState(() {});
  }

  List<Container> createDataTableHeaders() {
    List<Container> myHeaders = [];
    // create default transaction for display
    if (currentTransactions.isEmpty) {
      currentTransactions.add(Transaction());
    }

    // use the first transaction for layout
    Map<String, dynamic> props = currentTransactions[0].getProperties();
    int cindex = 0;
    props.forEach((header, value) {
      // loop through the transaction to get the columns
      double cwidth = 150;
      BoxDecoration decoration;
      Color headerColor = Colors.blueAccent;
      if(header.length < 3) {
        cwidth = 80;
      } else if (header.length < 7) {
        cwidth = 90;
      }
      if (cindex == 0) {
        decoration = BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
            color: headerColor
        );
      } else if(cindex == props.length-1) {
        decoration = BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
            color: headerColor
        );
      } else {
        decoration = BoxDecoration(
          color: headerColor
        );
      }
      myHeaders.add(        
        Container(
          decoration: decoration,
          width: cwidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(header),
              getColumnIcon(cindex)  // dynamically generate icon based on sorting state
            ]
          ),
        )
      );
      columnSizes.addEntries([MapEntry(cindex, FixedColumnWidth(cwidth))]);
      cindex++;
    });
    return myHeaders;
  }

  Table createDataTable() {
    List<TableRow> myRows = [];

    // loop through the transactions to create the cells and rows
    int index = 0;
    for (List<String> row in currentTransactionStrings) {
      List<TableCell> myCells = [];
      for (String cell in row) {
        myCells.add(
          TableCell(
            child: Container(
              height: 30,
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
              color: index % 2 != 0 ? Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 201, 240, 255),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(cell)),
            ),
          )
        );
      }
      myRows.add(
        TableRow(
          children: myCells,
        )
      );
      index++;
    }
    return Table(
        border: TableBorder.symmetric(),
        columnWidths: columnSizes,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: myRows,
      );
  }

  void sortMe(int cindex) {
    // get transactions as a map array
    List<Map<String,dynamic>> sortedTransactionMap = [];
    for (Transaction ctr in currentTransactions) {
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

      // check for which data type we are looping through
      if (trans is Transaction) {
        transrow = trans.getProperties();
      } else if (trans is Map<String,dynamic>) {
        transrow = trans;
      }

      // parse the row
      transrow.forEach((header, value) {
        String val = '';
        if (value is String) {
          // string values don't require any parsing
          val = value;
        } else if (value is DateTime) {
          if (value == DateTime.parse('9999-99-99')) {
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
