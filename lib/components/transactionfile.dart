import 'dart:io';
import 'package:budgetbuddy/components/appconfig.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

class TransactionFile {
  File file;  // the actual transaction file
  String? headers;  // headers for the file (used in identifying the account type)
  List<List<dynamic>> csvData = [];   // raw data from the csv
  List<TransactionObj> data = [];   // transactionObjs loaded from the csv
  String account = '';  // will be loaded with the account name
  DatabaseService dbs = DatabaseService();
  Appconfig appconfig = Appconfig();

  TransactionFile(this.file);

  Future<bool> load() async {
    bool status = await readFile(file);
    status = await identifyAccount();
    status = loadTransactionObjs();
    return status;
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
            // key is present therefore place the value of the csv into the transaction map
            String transObjKey = appconfig.accountInfo![account]['format'][key];
            transactionMap[transObjKey] = value;
          } else {
            debugPrint("Key does not exists -> $key");
          }
        }
        // done going through columns, add transactionobj to list
        TransactionObj currentTrans = TransactionObj.loadFromMap(transactionMap);
        data.add(currentTrans);
        debugPrint("New transaction obj:");
        print(currentTrans.getProperties());
      }
      return true;
    }
    return false;
  }

  void addTransactionToDatabase() async {
    // check to make sure the account exists first
    if (!await dbs.checkIfAccountExists(account)) {
      dbs.addAccount(account);
    }
    // go through the list of transactionobjs and add the database
    for (TransactionObj trans in data) {
      dbs.addTransaction(trans);
    }
  }
}
