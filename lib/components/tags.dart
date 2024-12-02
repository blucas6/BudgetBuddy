

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

  bool isIncome(TransactionObj trans) {
    // check for income tag
    if (trans.tags.contains(INCOME)) return true;
    return false;
  }

  bool isSavings(TransactionObj trans) {
    // check for savings tag
    if (trans.tags.contains(SAVINGS)) return true;
    return false;
  }

  bool isValid(TransactionObj trans) {
    // check for hidden tag
    if (trans.tags.contains(HIDDEN)) return false;
    return true;
  }

  bool isRent(TransactionObj trans) {
    // check for rent tag
    if (trans.tags.contains(RENT)) return true;
    return false;
  }
}