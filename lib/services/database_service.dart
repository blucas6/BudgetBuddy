import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'task.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();
  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
    // Custom path for the database file
    final customPath = 'C:\\Users\\YAsh\\Downloads\\master_db.db';

    // Ensure the directory exists
    final directory = Directory(dirname(customPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print("Directory created: ${directory.path}");
    } else {
      print("Directory already exists: ${directory.path}");
    }

    // Open or create the database at the custom location
    final database = await openDatabase(
      customPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_tasksTableName (
            $_tasksIdColumnName INTEGER PRIMARY KEY,
            $_tasksContentColumnName TEXT NOT NULL,
            $_tasksStatusColumnName INTEGER NOT NULL
          )
        ''');
      },
    );

    print("Database initialized at: $customPath");
    return database;
  }

  // CRUD Operations
  Future<bool> addTransaction(String content) async {
    try {
      final db = await database;
      await db.insert(
        _tasksTableName,
        {
          _tasksContentColumnName: content,
          _tasksStatusColumnName: 0,
        },
      );
      print("Transaction added: $content");
      return true;
    } catch (e) {
      print('Add transaction failed: $e');
      return false;
    }
  }

  Future<List<Task>> getTransactions() async {
    try {
      final db = await database;
      final data = await db.query(_tasksTableName);
      return data
          .map((e) => Task(
                id: e[_tasksIdColumnName] as int,
                status: e[_tasksStatusColumnName] as int,
                content: e[_tasksContentColumnName] as String,
              ))
          .toList();
    } catch (e) {
      print('Read transactions failed: $e');
      return [];
    }
  }

  Future<bool> updateTransactionStatus(int id, int status) async {
    try {
      final db = await database;
      int count = await db.update(
        _tasksTableName,
        {
          _tasksStatusColumnName: status,
        },
        where: '$_tasksIdColumnName = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Update transaction failed: $e');
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final db = await database;
      int count = await db.delete(
        _tasksTableName,
        where: '$_tasksIdColumnName = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      print('Delete transaction failed: $e');
      return false;
    }
  }

  // Verification Method
  Future<void> printAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(_tasksTableName);

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
