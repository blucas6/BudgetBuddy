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
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      TransactionFile tfile = TransactionFile(file);
      bool status = await tfile.load();
      if (status) {
        // identify name of the account
        account = tfile.account;
        debugPrint("Identified Account: $account");
        if (account.isNotEmpty) {
          debugPrint("Adding transactions to database");
          // if account name exists in config, tell the object to add the file data to the database
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
              content: const Text('Unsupported account type!'),
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
    return Column(
      children: <Widget>[
        const Text('Accounts'),
        Column(children: accountList.map((text) => Text(text)).toList()),
        TextButton(
          onPressed: addNewAccount,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(255, 12, 183, 226),
            ),
          ),
          child: const Text('+'),
        ),
      ],
    );
  }
}
