import 'package:flutter/material.dart';

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({super.key});
  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  void loadTransactions() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text('Transactions'),
      ],
    );
  }
}
