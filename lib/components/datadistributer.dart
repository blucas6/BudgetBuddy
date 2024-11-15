import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:budgetbuddy/components/transactionfile.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';

class Datadistributer {
  Datadistributer() {
    loadPipeline();
  }

  final Completer<void> _initCompleter = Completer<void>();

  Future<void> ensureInitialized() async {
    return _initCompleter.future;
  }

  List<TransactionObj> _allTransactions = [];
  List<String> _allAccounts = [];

  Future<List<TransactionObj>> get allTransactions async {
    await ensureInitialized();
    return _allTransactions;
  }

  Future<List<String>> get allAccounts async {
    await ensureInitialized();
    return _allAccounts;
  }

  // connection to database
  DatabaseService dbs = DatabaseService();

  // gathers all data for other widgets to use
  Future<void> loadPipeline() async {
    if (_initCompleter.isCompleted) {
      _initCompleter.future;
    }
    _allTransactions = await dbs.getTransactions();
    _allAccounts = await loadAccountList();
    _initCompleter.complete();
    debugPrint("Done loading data pipeline!");
  }

  // adds a transactions from a transaction file to the database
  Future<bool> addTransactionFileToDatabase(TransactionFile tfile) async {
    try {
      if (!await dbs.checkIfAccountExists(tfile.account)) {
        dbs.addAccount(tfile.account);
      }
      // go through the list of transactionobjs and add the database
      for (TransactionObj trans in tfile.data) {
        dbs.addTransaction(trans);
      }
      // reload updated data
      await loadPipeline();
      return true;
    } catch (e) {
      debugPrint('Unable to load new data from ${path.basename(tfile.file.path)} database -> $e');
    }
    return false;
  }

  // updates a single transaction
  Future<bool> updateData(int id, String column, String value) async {
    // TODO: Pass old and new transaction and let this function determine
    // the values that changed to update the database
    bool success =  await dbs.updateTransactionByID(id, column, value);
    // reload all data when updating the database
    await loadPipeline();
    return success;
  }

  // gets all the accounts added as a list
  Future<List<String>> loadAccountList() async {
    List<Map<String,dynamic>> accounts = await dbs.getAllAccounts();
    List<String> accountlist = [];
    for (Map<String,dynamic> row in accounts) {
      accountlist.add(row['name']);
    }
    return accountlist;
  }

  // get the total spending over a period
  Future<Map<String,double>> loadProfile() async {
    await ensureInitialized();
    double totalspending = 0;
    double totalincome = 0;
    for (TransactionObj row in _allTransactions) {
      if (row.cost! < 0) {
        totalspending += row.cost!;
      } else {
        totalincome += row.cost!;
      }
    }
    return {
      'totalspending': totalspending,
      'totalincome': totalincome,
      'totalassets': totalincome + totalspending
      };
  }

  // returns the structure:
  // { <year1> : [month1, month2, ...],
  //   <year2> : [month4, month5, ..] }
  Future<Map<String, dynamic>> getTotalDateRange() async {
    await ensureInitialized();
    Map<String, dynamic> totalRange = {};
    for (TransactionObj row in _allTransactions) {
      // check if year is in map
      if (!totalRange.containsKey(row.year)) {
        // if not, add it
        totalRange[row.year] = [];
      }
      // first check if month has an associated year in map
      if (totalRange.containsKey(row.year)
      && !totalRange[row.year].contains(row.month)) {
        // if not, add it
        totalRange[row.year].add(row.month);
      }
    }
    return totalRange;
  }

}