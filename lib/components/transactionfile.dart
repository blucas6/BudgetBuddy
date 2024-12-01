import 'dart:io';
import 'package:budgetbuddy/config/appconfig.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';

class TransactionFile {
  File file;
  String? headers;
  List<List<dynamic>> csvData = [];
  List<TransactionObj> data = [];
  String account = '';
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
    if (appconfig.accountInfo != null) {
      for (var accounttype in appconfig.accountInfo!.keys) {
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
    if (file.path.endsWith('.csv')) {
      String csvDataStr = await file.readAsString();
      csvData = const CsvToListConverter().convert(csvDataStr);
      headers = csvData[0].join(',');
      debugPrint("CSV Headers: $headers");
      return true;
    } else if (file.path.endsWith('.xlsx')) {
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      var firstTable = excel.tables[excel.tables.keys.first];
      if (firstTable != null) {
        csvData = firstTable.rows;
        headers = firstTable.rows[0]
            .map((cell) => cell?.value != null ? cell?.value.toString() : '')
            .join(',');
        debugPrint("Excel Headers: $headers");
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
      Map<String, dynamic> transactionMap = TransactionObj().getBlankMap();
      for (var i = 1; i < csvData.length; i++) {
        for (var j = 0; j < csvData[0].length; j++) {
          String key = csvData[0][j];
          dynamic value = csvData[i][j];
          if (appconfig.accountInfo![account]['format'].containsKey(key)) {
            String transObjKey = appconfig.accountInfo![account]['format'][key];
            transactionMap[transObjKey] = value;
          } else {
            debugPrint("Key does not exist -> $key");
          }
        }
        TransactionObj currentTrans =
            TransactionObj.loadFromMap(transactionMap);
        data.add(currentTrans);
        debugPrint("New transaction obj:");
        print(currentTrans.getProperties());
      }
      return true;
    }
    return false;
  }

  void addTransactionToDatabase() {
    for (TransactionObj trans in data) {
      dbs.addTransaction(trans);
    }
  }

  Future<void> deleteTransactionsByAccount() async {
    bool result = await dbs.deleteTransactionsByAccount(account);
    if (result) {
      debugPrint("All transactions for account $account deleted successfully.");
    } else {
      debugPrint("Failed to delete transactions for account $account.");
    }
  }

  Future<void> deleteFile() async {
    if (await file.exists()) {
      await file.delete();
      debugPrint("File deleted.");
    } else {
      debugPrint("File not found for deletion.");
    }
  }
}
