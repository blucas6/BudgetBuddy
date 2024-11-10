import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:budgetbuddy/components/transactionfile.dart';

class AccountBar extends StatefulWidget {
  const AccountBar({super.key});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = [];

  Future<void> addNewAccount() async {
    String account = '';
    // Ask user for a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      TransactionFile tfile = TransactionFile(file);
      bool status = await tfile.load();
      if (status) {
        account = tfile.account;
        debugPrint("Identified Account: $account");
        if (account.isNotEmpty) {
          debugPrint("Adding transactions to database");
          tfile.addTransactionToDatabase();
        }
      } else {
        debugPrint("Error loading transaction file!");
      }
    }

    setState(() {
      if (account.isNotEmpty) {
        accountList.add(account);
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Unsupported account type! Please check your file and try again.'),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Accounts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            children: accountList
                .map((account) => Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(account, style: const TextStyle(fontSize: 16)),
                      ],
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: addNewAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 12, 183, 226),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('+ Add Account', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
