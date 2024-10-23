import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';
import 'dart:html' as html;

class IndexedDBService {
  static const String dbName = 'BudgetBuddyDB';
  static const String storeName = 'transactions';
  Database? _db;

  Future<void> init() async {
    if (_db == null) {
      final idbFactory = getIdbFactory(html.window as String?);
      _db = await idbFactory!.open(
        dbName,
        version: 1,
        onUpgradeNeeded: (e) {
          final db = e.database;
          db.createObjectStore(storeName, keyPath: 'id', autoIncrement: true);
        },
      );
    }
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    await store.add(transaction);
    await txn.completed;
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final txn = _db!.transaction(storeName, idbModeReadOnly);
    final store = txn.objectStore(storeName);
    final allRecords = await store.getAll();
    return allRecords.cast<Map<String, dynamic>>();
  }

  Future<void> updateTransaction(int id, Map<String, dynamic> updatedTransaction) async {
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    updatedTransaction['id'] = id; // Ensure the id is included
    await store.put(updatedTransaction);
    await txn.completed;
  }

  Future<void> deleteTransaction(int id) async {
    final txn = _db!.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    await store.delete(id);
    await txn.completed;
  }
}
