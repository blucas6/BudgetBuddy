import 'dart:io';
import 'package:budgetbuddy/components/appconfig.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

class TransactionFile {
  File file;                                // the actual transaction file
  String? headers;                          // headers for the file (used in identifying the account type)
  List<List<dynamic>> csvData = [];         // raw data from the csv
  List<TransactionObj> data = [];           // transactionObjs loaded from the csv
  String account = '';                      // will be loaded with the account name
  DatabaseService dbs = DatabaseService();  // connection to database instance
  Appconfig appconfig = Appconfig();        // application config for parsing values

  TransactionFile(this.file);

  // on load, locate the account name and load all data
  Future<bool> load() async {
    bool readfilestatus = await readFile(file);
    bool identifyaccountstatus = await identifyAccount();
    bool loadtransactionsstatus = loadTransactionObjs();
    return readfilestatus && identifyaccountstatus && loadtransactionsstatus;
  }

  Future<bool> identifyAccount() async {
    // check config is loaded
    if (appconfig.accountInfo != null) {
      // loop through all accounts (keys)
      for (var accounttype in appconfig.accountInfo!.keys) {
        // if an account matches the 'headers' specifier, match that account
        if (appconfig.accountInfo![accounttype]['headers'] == headers) {
          debugPrint("Account type matched: $account");
          account = accounttype;
          return true;
        }
      }
    } else {
      debugPrint('Config not loaded!');
    }
    return false;
  }

  Future<bool> readFile(File file) async {
    // Check the file extension to determine how to read the file
    if (file.path.endsWith('.csv')) {
      String csvDataStr = await file.readAsString();
      // get the data in a list
      csvData = const CsvToListConverter().convert(csvDataStr);
      // get the headers in a string
      headers = csvData[0].join(',');
      debugPrint("CSV Headers: $headers");
      return true;
    } else if (file.path.endsWith('.xlsx')) {
      // Read Excel file
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      var firstTable = excel.tables[excel.tables.keys.first];
      if (firstTable != null) {
        csvData = firstTable.rows;
        headers = firstTable.rows[0].map((cell) => 
                cell?.value != null
                ? cell?.value.toString()
                : ''
              ).join(',');
        debugPrint("Excel Headers: $headers");
        // Debugging each row
        for (var row in firstTable.rows) {
          debugPrint("Row data: ${row.map((cell) => cell?.value).toList()}");
        }
        return true;
      } else {
        debugPrint("No tables found in Excel file.");
        return false;
      }
    } else {
      return false;
    }
  }

  bool loadTransactionObjs() {
    if (appconfig.accountInfo != null) {
      // start with a default map with all keys already created
      Map<String, dynamic> transactionMap = TransactionObj().getBlankMap();
      // loop through starting at the first row of data
      for (var i=1; i<csvData.length; i++) {
        // loop through each column in that row
        for (var j=0; j<csvData[0].length; j++) {
          String key = csvData[0][j];
          dynamic value = csvData[i][j];
          // check if config maps the given key to a transactionobj key
          if (appconfig.accountInfo![account]['format'].containsKey(key)) {
            // load the format to check for additional parsing
            Map<String,dynamic> keyFormat = appconfig.accountInfo![account]['format'][key];
            // if a value requires addional parsing, check the 'parsing' key
            if (keyFormat.containsKey('parsing')) {
              // check the type of parsing
              if (keyFormat['parsing'] == 'dateformat') {
                // check the parsing format for the proper datetime parsing format
                value = DateFormat(keyFormat['formatter']).parse(value);
              } else if (keyFormat['parsing'] == 'spending' && keyFormat['formatter'] == 'inverse') {
                value = -value.toDouble();
              }
            }
            // key is present therefore place the value of the csv into the transaction map
            transactionMap[keyFormat['column']] = value;
          } else {
            // debugPrint("Key does not exists -> $key");
          }
        }
        // add account type as a column
        transactionMap['Account'] = account;
        // done going through columns, add transactionobj to list
        TransactionObj currentTrans = TransactionObj.loadFromMap(transactionMap);
        data.add(currentTrans);
      }
      return true;
    }
    return false;
  }
}
