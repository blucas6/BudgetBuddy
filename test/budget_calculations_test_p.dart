//budget calc
import 'package:flutter_test/flutter_test.dart';
//import 'package:intl/intl.dart';

// Define the TransactionObj class
class TransactionObj {
  final double cost;
  final DateTime date;
  final String description;

  TransactionObj({
    required this.cost,
    required this.date,
    required this.description,
  });
}

// Calculate the monthly total spending
double calculateMonthlyTotal(List<TransactionObj> transactions, DateTime now) {
  return transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .fold(0.0, (sum, t) => sum + t.cost);
}

// Calculate the 50/30/20 rule for budgeting
Map<String, double> calculateBudgetRule(double income) {
  return {
    'Needs': income * 0.50,
    'Wants': income * 0.30,
    'Savings': income * 0.20,
  };
}

void main() {
  group('Budget Calculations', () {
    test('Monthly spending total calculation', () {
      final now = DateTime(2024, 11, 15); // Fixed date for testing
      final transactions = [
        TransactionObj(
            cost: 50.0, date: DateTime(2024, 11, 15), description: 'Groceries'),
        TransactionObj(
            cost: 30.0, date: DateTime(2024, 11, 2), description: 'Transport'),
        TransactionObj(
            cost: 20.0, date: DateTime(2024, 10, 31), description: 'Utilities'),
      ];

      final total = calculateMonthlyTotal(transactions, now);
      expect(total, 80.0); // Only transactions from November 2024 are included
      print('Monthly spending total calculation test successful');
    });

    test('50/30/20 Rule Calculation', () {
      final income = 1000.0;
      final rule = calculateBudgetRule(income);

      expect(rule['Needs'], 500.0); // 50% for needs
      expect(rule['Wants'], 300.0); // 30% for wants
      expect(rule['Savings'], 200.0); // 20% for savings
      print('50/30/20 Rule Calculation test successful');
    });
  });
}
