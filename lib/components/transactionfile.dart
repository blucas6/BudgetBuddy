import 'dart:io';
import 'package:budgetbuddy/config/appconfig.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

class TransactionFile {
  File file;
  TransactionFile(this.file);

  Future<String> identifyAccount() async {
    String? headers;

    // Check the file extension to determine how to read the file
    if (file.path.endsWith('.csv')) {
      String csvData = await file.readAsString();
      headers = const CsvToListConverter().convert(csvData)[0].join(',');
      print("CSV Headers: $headers");
    } else if (file.path.endsWith('.xlsx')) {
      // Read Excel file
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      var firstTable = excel.tables[excel.tables.keys.first];
      if (firstTable != null) {
        headers = firstTable.rows[0]
            .map((cell) => cell?.value != null
                ? cell?.value.toString()
                : '') // Handle null values
            .join(',');
        print("Excel Headers: $headers");

        // Debugging each row
        for (var row in firstTable.rows) {
          print("Row data: ${row.map((cell) => cell?.value).toList()}");
        }
      } else {
        print("No tables found in Excel file.");
      }
    }

    Appconfig appconfig = Appconfig();
    if (appconfig.accountTypes != null) {
      for (var account in appconfig.accountTypes!.keys) {
        if (appconfig.accountTypes![account] == headers) {
          print("Account type matched: $account");
          return account;
        }
      }
    } else {
      debugPrint('Config not loaded!');
    }
    return '';
  }
}
