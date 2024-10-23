import 'package:flutter/material.dart';
import 'package:budgetbuddy/services/database_service.dart';

class TransactionWidget extends StatefulWidget {
  final String accountNumber;

  const TransactionWidget({super.key, required this.accountNumber});
  
  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  List<Map<String, dynamic>> transactionList = [];
  final DatabaseService dbService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    transactionList = await dbService.getTransactions(widget.accountNumber);
    setState(() {});
  }

  Future<void> deleteTransaction(int id) async {
    await dbService.deleteTransaction(id);
    await loadTransactions(); // Refresh transaction list
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Transactions'),
        Column(
          children: transactionList.map((transaction) {
            return Row(
              children: [
                Expanded(child: Text(transaction['description'])),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteTransaction(transaction['id']),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
