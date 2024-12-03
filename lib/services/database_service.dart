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

  // Tablenames
  static final String transactionTableName = "transactions";
  static final String accountTableName = "accounts";

  DatabaseService._constructor() {
    // setup the database on constructor call
    loadDatabase();
  }

  // database getter
  Future<Database> get database async {
    // database getter
    if (_db != null) return _db!;
    _db = await loadDatabase();
    return _db!;
  }

  // loads the database if it doesn't exist
  Future<Database> loadDatabase() async {
    // get user area
    final databaseDirPath = await getApplicationSupportDirectory();
    final databasePath = join(databaseDirPath.path, "master_db.db");

    String query = '';
    int index = 0;
    TransactionObj.defaultTransaction().getSQLProperties().forEach((name, value) {
      query += '$name $value';
      index++;
      if (index != TransactionObj().getProperties().keys.length) {
        query += ', ';
      }
    });
    // Open or create the database at the custom location'
    dynamic db;
    try {
      db = await openDatabase(
            databasePath,
            version: 1,
            onCreate: (db, version) async {
              await db.execute("""
                PRAGMA foreign_keys = ON;
                CREATE TABLE IF NOT EXISTS $accountTableName (name TEXT NOT NULL);
                CREATE TABLE IF NOT EXISTS $transactionTableName ($query,
                FOREIGN KEY (Account) REFERENCES $accountTableName(name));
              """);
            },
          );
    } catch (e) {
      debugPrint("Failed to connect to database! -> $e");
    }
    debugPrint("Database initialized at: $databasePath");
    return db;
  }

  // returns whether an account exists or not
  Future<bool> checkIfAccountExists(String accountName) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> result = await db.rawQuery(
        "SELECT * FROM $accountTableName WHERE name = '$accountName'"
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // returns all the accounts in the account table as a list
  Future<List<Map<String,dynamic>>> getAllAccounts() async {
    try {
      final db = await database;
      return await db.query(accountTableName);
    } catch (e) {
      debugPrint("Accounts query failed -> $e");
      return [{}];
    }
  }

  // adds an account type to the account table name
  Future<bool> addAccount(String accountName) async {
    // accounts must be added before transaction data because of the
    // foreign key constraint
    try {
      final db = await database;
      await db.insert(accountTableName, {'name': accountName});
      debugPrint("Account added: $accountName");
      return true;
    } catch (e) {
      debugPrint('Add account failed: $e');
      return false;
    }
  }

  // adds a singular transaction to the transaction table
  Future<bool> addTransaction(TransactionObj trans) async {
    try {
      // sqlite will increment the id, so provide a map with no id
      final db = await database;
      await db.insert(transactionTableName, trans.getPropertiesNoID());
      debugPrint("Transaction added: ");
      print(trans.getProperties());
      return true;
    } catch (e) {
      debugPrint('Add transaction failed: $e');
      return false;
    }
  }

  // gets all transactions
  Future<List<TransactionObj>> getTransactions() async {
    try {
      final db = await database;
      final data = await db.query(transactionTableName);
      // make use of transactionobj interface
      // create objects to return from database
      return data.map((entry) => TransactionObj.loadFromMap(entry)).toList();
    } catch (e) {
      debugPrint('Read transactions failed: $e');
    }
    return [];
  }

  // updates a transaction in the database by its id
  Future<bool> updateTransactionByID(int id, String column, dynamic value) async {
    // pass an id to update a transaction at a given column with a certain value
    try {
      final db = await database;
      int count = await db.update(
        transactionTableName,
        {column: value},
        where: 'ID = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Update transaction failed: $e');
      return false;
    }
  }

  // deletes a transaction by its id
  Future<bool> deleteTransaction(int id) async {
    try {
      final db = await database;
      int count = await db.delete(
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

  // Delete all transactions by account
  Future<bool> deleteTransactionsByAccount(String account) async {
    try {
      int count = await _db!.delete(
        transactionTableName,
        where: 'account = ?',
        whereArgs: [account],
      );
      return count > 0;
    } catch (e) {
      debugPrint('Delete transactions by account failed: $e');
      return false;
    }
  }

  Future<void> printAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(transactionTableName);
    if (results.isNotEmpty) {
      debugPrint('--- Transactions in Database ---');
      print(results);
      debugPrint('-------------------------------');
    } else {
      debugPrint('No transactions found in the database.');
    }
  }
}
