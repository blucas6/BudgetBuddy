import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budgetbuddy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(
      join(await getDatabasesPath(), filePath),
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountNumber TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountNumber TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        spending REAL NOT NULL
      )
    ''');
  }

  Future<void> insertAccount(String accountNumber, String description) async {
    final db = await instance.database;
    await db.insert(
      'accounts',
      {'accountNumber': accountNumber, 'description': description},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTransaction(String accountNumber, String description, String category, double spending) async {
    final db = await instance.database;
    await db.insert(
      'transactions',
      {
        'accountNumber': accountNumber,
        'description': description,
        'category': category,
        'spending': spending
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions');
  }
}
