import 'dart:io';
import 'package:budgetbuddy/config/appconfig.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

class TransactionFile {
  // Object to represent the transaction file that users will upload
  // Create this object by passing it the file object
  File file;
  TransactionFile(this.file);

  // Method to return the account type from the uploaded transactions
  Future<String> identifyAccount() async {
    String csvData = await file.readAsString();
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
    String headers = rows[0].join(',');
    Appconfig appconfig = Appconfig();
    if (appconfig.accountTypes != null) {
      for (var account in appconfig.accountTypes!.keys) {
        if (appconfig.accountTypes![account] == headers) {
          return account;
        }
      }
    } else {
      debugPrint('config not loaded!');
    }
    return '';
  }
}