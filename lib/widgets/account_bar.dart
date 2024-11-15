import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:budgetbuddy/components/transactionfile.dart';

class AccountBar extends StatefulWidget {
  // this callback triggers the main app to reload all widgets
  final void Function() newDataTrigger;
  final Datadistributer datadistributer;
  const AccountBar({super.key, required this.newDataTrigger, required this.datadistributer});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = [];
  @override 
  void initState() {
    super.initState();
    loadAccounts();
  }

  void loadAccounts() async {
    // on load, get previously stored data from the db
    accountList = await widget.datadistributer.loadAccountList();
    setState(() {});
  }

  Future<void> addNewAccount() async {
    String account = '';
    // ask user for a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // load the file
      File file = File(result.files.single.path!);
      // load the transactionFile object from the file
      TransactionFile tfile = TransactionFile(file);
      bool status = await tfile.load();
      // if loading completed try to identify the account
      if (status) {
        // identify name of the account
        account = tfile.account;
        debugPrint("Identified Account: $account");
        // if account name exists in config, tell the object to add the file data to the database
        if (account.isNotEmpty) {
          debugPrint("Adding transactions to database");
          // load new data to database
          await widget.datadistributer.addTransactionFileToDatabase(tfile);
          // load accounts list, data distributer should be up to date
          accountList = await widget.datadistributer.loadAccountList();
        }
      } else {
        debugPrint("Error loading transaction file!");
      }
    }

    setState(() {
      if (account.isNotEmpty) {
        // trigger the callback to reload all widgets
        widget.newDataTrigger();
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
