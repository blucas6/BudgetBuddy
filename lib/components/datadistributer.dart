import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:budgetbuddy/components/transactionfile.dart';
import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';

class Datadistributer {
  // This object serves as a data pipeline from the database
  // to the application widgets

  List<TransactionObj> _allTransactions = [];   // holds all transactions available from the database
  List<String> _allAccounts = [];               // holds a list of accounts available from the database
  DatabaseService dbs = DatabaseService();      // connection to database

  // load the pipeline on instantiation
  Datadistributer() {
    loadPipeline();
  }

  // keeps track if the pipeline is ready or not
  // _initCompleter will be false if not done grabbing data
  final Completer<void> _initCompleter = Completer<void>();

  // method that will wait on the _initCompleter to be done
  Future<void> ensureInitialized() async {
    return _initCompleter.future;
  }

  // getter for the internal allTransactions object
  // will wait for the pipeline to be done
  Future<List<TransactionObj>> get allTransactions async {
    await ensureInitialized();
    return _allTransactions;
  }

  // getter for the internal allAccounts object
  // will wait for the pipeline to be done
  Future<List<String>> get allAccounts async {
    await ensureInitialized();
    return _allAccounts;
  }

  // gathers all data for other widgets to use
  Future<void> loadPipeline() async {
    // if pipeline has already been loaded previously
    if (_initCompleter.isCompleted) {
      // reset it so that other objects will know the
      // pipeline is not currently ready
      _initCompleter.future;
    }
    // gather all necessary data
    _allTransactions = await dbs.getTransactions();
    _allAccounts = await loadAccountList();
    // label pipeline as ready
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
    debugPrint("Done loading data pipeline!");
  }

  // adds a transactions from a transaction file to the database
  Future<bool> addTransactionFileToDatabase(TransactionFile tfile) async {
    try {
      // add the new account to the account table if it does not exist already
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
    // no need to reload the entire pipeline just update the internal value
    for (int t=0; t<_allTransactions.length; t++) {
      // find matching transaction
      if (_allTransactions[t].id == id) {
        // get the properties as a map
        Map<String,dynamic> props = _allTransactions[t].getProperties();
        // change the value
        props[column] = value;
        // replace the index with the new object
        _allTransactions[t] = TransactionObj.loadFromMap(props);
      }
    }
    return success;
  }

  // loads all the accounts as a list
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

  // fetches a data range for the user to filter transactions by
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

  Future<bool> deleteTransactionsByAccount(String account) async {
    return dbs.deleteTransactionsByAccount(account);
  }

}