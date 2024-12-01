import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:budgetbuddy/components/transactionfile.dart';
import 'package:budgetbuddy/services/database_service.dart';

class AccountBar extends StatefulWidget {
  const AccountBar({super.key});

  @override
  State<AccountBar> createState() => _AccountBarState();
}

class _AccountBarState extends State<AccountBar> {
  List<String> accountList = []; // List of account names
  final dbService = DatabaseService();

  // Add a new account based on the selected file
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

  // Delete the selected file from local storage and the associated data from the database
  Future<void> deleteAccountData(String account) async {
    try {
      // Delete the file associated with the account
      final filePath = await getFilePathForAccount(account);
      if (filePath != null) {
        File file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          print("File deleted from storage.");
        }
      }

      // Delete associated data from the database
      await dbService.deleteTransactionsByAccount(account);
      print("Associated data deleted from database.");
    } catch (e) {
      print("Error deleting account data: $e");
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
            children: accountList
                .map((account) => Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(account, style: const TextStyle(fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Account'),
                                  content: Text(
                                      'Are you sure you want to delete the $account account and its data?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
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
