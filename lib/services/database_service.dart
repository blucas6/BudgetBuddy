import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:budgetbuddy/services/transaction.dart';

class DatabaseService {
  // currently loads the database at: C:\Users\<user>\AppData\Roaming\com.example\budgetbuddy (windows)
  static Database? _db;
  static final DatabaseService _instance = DatabaseService._constructor();
  factory DatabaseService() => _instance;

  static final String transactionTableName = "transactions";

  DatabaseService._constructor() {
    loadDatabase();
  }

  void loadDatabase() async {
    // get user area
    final databaseDirPath = await getApplicationSupportDirectory();
    final databasePath = join(databaseDirPath.path, "master_db.db");

    // create query string from a template object
    String query = '';
    String type = 'TEXT';
    String restriction = 'NOT NULL';
    int index = 0;
    TransactionObj.defaultTransaction().getProperties().forEach((name, value) {
      // dynamic typing of values
      if (value is int?) {
        type = 'INTEGER';
      } else if (value is DateTime) {
        type = 'DATE';
      } else if (value is double?) {
        type = 'DOUBLE';
      } else {
        type = 'TEXT';
      }
      // set primary key to first column
      if (index == 0) {
        restriction = 'PRIMARY KEY AUTOINCREMENT';
      } else {
        restriction = 'NOT NULL';
      }
      query += '$name $type $restriction';
      index++;
      // add divider except for the last value
      if (index != TransactionObj().getProperties().keys.length) {
        query += ', ';
      }
    });
    debugPrint("Running query: $query");
    // Open or create the database at the custom location
    try {
      _db = await openDatabase(
            databasePath,
            version: 1,
            onCreate: (db, version) async {
              await db.execute("CREATE TABLE IF NOT EXISTS $transactionTableName ($query)");
            },
          );
    } catch (e) {
      debugPrint("Failed to connect to database! -> $e");
    }
    debugPrint("Database initialized at: $databasePath");
  }

  Future<bool> addTransaction(TransactionObj trans) async {
    try {
      // give the added transaction an id and increment
      await _db!.insert(transactionTableName, trans.getPropertiesNoID());
      debugPrint("Transaction added: ");
      print(trans.getProperties());
      return true;
    } catch (e) {
      debugPrint('Add transaction failed: $e');
      return false;
    }
  }

  Future<List<TransactionObj>> getTransactions() async {
    try {
      final data = await _db!.query(transactionTableName);
      // make use of transactionobj interface
      // create objects to return from database
      return data.map((entry) => TransactionObj.loadFromMap(entry)).toList();
    } catch (e) {
      debugPrint('Read transactions failed: $e');
      return [];
    }
  }

  Future<bool> updateTransactionByID(int id, String column, dynamic value) async {
    // pass an id to update a transaction at a given column with a certain value
    try {
      int count = await _db!.update(
        transactionTableName,
        {
          column: value,
        },
        where: 'ID = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Update transaction failed: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    // pass an id and delete the column at that id
    try {
      int count = await _db!.delete(
        transactionTableName,
        where: 'ID = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      debugPrint('Delete transaction failed: $e');
      return false;
    }
  }

  // Verification Method
  Future<void> printAllTransactions() async {
    final List<Map<String, dynamic>> results = await _db!.query(transactionTableName);

    if (results.isNotEmpty) {
      debugPrint('--- Transactions in Database ---');
      print(results);
      debugPrint('-------------------------------');
    } else {
      debugPrint('No transactions found in the database.');
    }
  }
}
