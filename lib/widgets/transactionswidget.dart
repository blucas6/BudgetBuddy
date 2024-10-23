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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Placeholder for transaction list
          const Text(
            'Transaction list goes here',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
