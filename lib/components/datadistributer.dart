import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';

class Datadistributer {
  Datadistributer._internal();

  static final Datadistributer _instance = Datadistributer._internal();

  factory Datadistributer() => _instance;

  // connection to database
  DatabaseService dbs = DatabaseService();

  // gets all available transactions from the database
  Future<List<TransactionObj>> loadData() async {
    return await dbs.getTransactions();
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
    double totalspending = 0;
    double totalincome = 0;
    List<TransactionObj> allTransactions = await dbs.getTransactions();
    for (TransactionObj row in allTransactions) {
      if (row.cost! < 0) {
        totalspending += row.cost!;
      } else {
        totalincome += row.cost!;
      }
    }
    return {
      'totalspending': totalspending,
      'totalincome': totalincome,
      'totalassets': totalincome - totalspending
      };
  }

}