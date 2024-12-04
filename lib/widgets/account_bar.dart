import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:budgetbuddy/components/transactionfile.dart';

class AccountBar extends StatefulWidget {
  // This object displays the account information

  final void Function() newDataTrigger;   // triggers a reload of all widgets
  final Datadistributer datadistributer;  // access to the data pipeline

  const AccountBar({super.key, required this.newDataTrigger, required this.datadistributer});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = [];  // all accounts available from the database

  @override 
  void initState() {
    super.initState();
    loadAccounts();
  }

  // on load, get data from the db
  void loadAccounts() async {
    accountList = await widget.datadistributer.loadAccountList();
    setState(() {});
  }

  // adds a new transaction file to the database
  Future<void> addNewAccount() async {
    String account = '';
    // Ask the user for a file
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

  // Delete the selected file from local storage and the associated data from the database
  Future<void> deleteAccountData(String account) async {
    try {
      // Delete the file associated with the account
      final filePath = await getFilePathForAccount(account);
      if (filePath != null) {
        File file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint("File deleted from storage.");
        }
      }

      // Delete associated data from the database
      bool success = await widget.datadistributer.deleteTransactionsByAccount(account);
      bool success2 = await widget.datadistributer.deleteAccount(account);
      if (success && success2) widget.newDataTrigger();
      debugPrint("Associated data deleted from database.");
    } catch (e) {
      debugPrint("Error deleting account data: $e");
    }

    setState(() {
      accountList.remove(account);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$account deleted successfully."),
    ));
  }

  // Mock function to fetch the file path for an account (replace with actual logic)
  Future<String?> getFilePathForAccount(String account) async {
    // Replace with logic to fetch the actual file path for the account
    return '/path/to/$account/file';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: accountList.map((account) => Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.blue),
                const SizedBox(width: 8),
                Text(account, style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Account'),
                          content: Text('Are you sure you want to delete the $account account and its data?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                deleteAccountData(account);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            )).toList(),
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
