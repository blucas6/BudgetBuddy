import 'dart:io';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AccountBar extends StatefulWidget {
  const AccountBar({super.key});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = [];
  List<String> transactions = []; // To store transaction values
  final DatabaseService dbService = DatabaseService.instance;

  Future<void> addNewAccount() async {
    String? accountNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Enter Account Number'),
          content: TextField(
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(hintText: 'Account Number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(input);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (accountNumber != null && accountNumber.isNotEmpty) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          String fileExtension = filePath.split('.').last.toLowerCase();
          if (['xlsx', 'xls', 'csv'].contains(fileExtension)) {
            File file = File(filePath);
            await processExcelFile(file, accountNumber);
            setState(() {
              accountList.add(accountNumber);
            });
          } else {
            showError('Invalid file type. Please select an Excel or CSV file.');
          }
        } else {
          showError('No file selected');
        }
      } else {
        showError('No file selected');
      }
    } else {
      showError('Invalid account number');
    }
  }

  Future<void> processExcelFile(File file, String accountNumber) async {
    try {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Assuming the first column has the transactions
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        for (var row in sheet.rows.skip(1)) { // Skip header if it exists
          String transactionValue = row[0]?.value.toString() ?? '0';
          double spending = double.tryParse(transactionValue) ?? 0.0;

          // Save transaction to the database
          await dbService.insertTransaction(
            accountNumber,
            'Transaction', // You can customize the description here
            'Default Category', // Assign a default category or modify as needed
            spending,
          );

          // Add transaction to the list for UI display
          transactions.add(transactionValue);
        }
      }

      // Store the account itself in the accounts table
      await dbService.insertAccount(accountNumber, 'Account Description');
    } catch (e) {
      showError('Failed to process file: $e');
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Accounts'),
        Column(
          children: accountList.map((text) => Text(text)).toList(),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: addNewAccount,
          child: const Text('+ Add Account'),
        ),
        const SizedBox(height: 20), // Add spacing
        const Text('Transactions'), // Title for transactions
        Column(
          children: transactions.map((transaction) => Text(transaction)).toList(),
        ),
      ],
    );
  }
}
