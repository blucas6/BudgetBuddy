import 'package:budgetbuddy/services/transaction.dart';
import 'package:flutter/material.dart';

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({super.key});
  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  List<Transaction> currentTransactions = [];
  void loadTransactions() {
    setState(() {});
  }

  DataTable createDataTable() {
    List<DataColumn> myColumns = [];
    List<DataRow> myRows = [];

    if (currentTransactions.isEmpty) {
      currentTransactions.add(Transaction(-1, '9999-99-99', -1, '', '', -1));
    }

    Map<String,dynamic> props = currentTransactions[0].getProperties();
    props.forEach((header, value) {
      
      myColumns.add(DataColumn(
        label: Text(header),
        numeric: value is int
        ));
    });

    for (Transaction ctr in currentTransactions) {
      List<DataCell> myCells = [];
      ctr.getProperties().forEach((header, value) {
        String val = '';
        if (value is String) {
          val = value;
        } else {
          val = value.toString();
        }
        myCells.add(DataCell(Text(val)));
      });
      myRows.add(DataRow(cells: myCells));
    }

    return DataTable(columns: myColumns, rows: myRows);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [createDataTable()]
    );
  }
}
