

import 'package:budgetbuddy/services/transaction.dart';

class Tags {
  String HIDDEN = 'Hidden';   // hides transaction from being counted in calculations
  String INCOME = 'Income';   // not counted as a refund
  String SAVINGS = 'Savings'; // not counted as spending, not subtracted from networth
  String RENT = 'Rent';       // Used for lifestyle calculations

  // determines transactions that are part of spending
  bool isTransactionSpending(TransactionObj trans) {
    // cannot be hidden
    if (trans.tags.contains(HIDDEN)) {
      return false;
    }
    // cannot be income - would lower spending
    if (trans.tags.contains(INCOME)) {
      return false;
    }
    // cannot be savings - would inflate spending
    if (trans.tags.contains(SAVINGS)) {
      return false;
    }
    return true;
  }
}