import 'package:flutter/material.dart';

// This widget displays a simple list of transactions
class TransactionWidget extends StatelessWidget {
  const TransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // A simple list of transactions as strings
    final List<String> transactions = [
      'Groceries - \$50', // First transaction: Groceries
      'Rent - \$1000',    // Second transaction: Rent
      'Utilities - \$150' // Third transaction: Utilities
    ];

    // The main UI layout of the widget
    return Column(
      children: <Widget>[
        // Display the title "Transactions"
        const Text(
          'Transactions',
          style: TextStyle(
            fontSize: 24,            
            fontWeight: FontWeight.bold
          ),
        ),
        
        const SizedBox(height: 20),  

        // Display each transaction as a simple text
        Column(
          // Use map to convert each transaction string to a Text widget
          children: transactions.map((transaction) {
            return Text(transaction); // Display each transaction as text
          }).toList(),  // Convert the map result to a list of widgets
        ),
      ],
    );
  }
}
