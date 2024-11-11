import 'package:budgetbuddy/services/database_service.dart';
import 'package:budgetbuddy/services/transaction.dart';

class Datadistributer {
  Datadistributer._internal();

  static final Datadistributer _instance = Datadistributer._internal();

  factory Datadistributer() => _instance;

  DatabaseService dbs = DatabaseService();

  Future<List<TransactionObj>> loadData() async {
    return await dbs.getTransactions();
  }

}