import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:budgetbuddy/services/transaction.dart';

class DatabaseService {
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

    // create query string from object
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
      debugPrint("Value $value has type $type");
      // set primary key to first column
      if (index == 0) {
        restriction = 'PRIMARY KEY';
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
    debugPrint("Running query: "+query);
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
    

    print("Database initialized at: $databasePath");
  }

  // CRUD Operations
  Future<bool> addTransaction(TransactionObj trans) async {
    try {
      await _db!.insert(transactionTableName, trans.getProperties());
      print("Transaction added: ");
      return true;
    } catch (e) {
      print('Add transaction failed: $e');
      return false;
    }
  }

  Future<List<TransactionObj>> getTransactions() async {
    try {
      final data = await _db!.query(transactionTableName);
      // make use of transactionobj interface
      return data.map((entry) => TransactionObj.loadFromMap(entry)).toList();
    } catch (e) {
      print('Read transactions failed: $e');
      return [];
    }
  }

  // Future<bool> updateTransactionStatus(int id, int status) async {
  //   try {
  //     final db = await database;
  //     int count = await db.update(
  //       _tasksTableName,
  //       {
  //         _tasksStatusColumnName: status,
  //       },
  //       where: '$_tasksIdColumnName = ?',
  //       whereArgs: [id],
  //     );
  //     return count > 0;
  //   } catch (e) {
  //     print('Update transaction failed: $e');
  //     return false;
  //   }
  // }

  // Future<bool> deleteTransaction(int id) async {
  //   try {
  //     final db = await database;
  //     int count = await db.delete(
  //       _tasksTableName,
  //       where: '$_tasksIdColumnName = ?',
  //       whereArgs: [id],
  //     );
  //     return count > 0;
  //   } catch (e) {
  //     print('Delete transaction failed: $e');
  //     return false;
  //   }
  // }

  // Verification Method
  Future<void> printAllTransactions() async {
    final List<Map<String, dynamic>> results = await _db!.query(transactionTableName);

    if (results.isNotEmpty) {
      print('--- Transactions in Database ---');
      for (var row in results) {
        print(row); // Prints each row in the table
      }
      print('-------------------------------');
    } else {
      print('No transactions found in the database.');
    }
  }
}
