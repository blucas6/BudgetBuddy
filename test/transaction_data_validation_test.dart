import 'package:flutter_test/flutter_test.dart';

class TransactionObj {
  final double amount;
  final DateTime date;
  final String description;

  TransactionObj({
    required this.amount,
    required this.date,
    required this.description,
  }) {
    // Validate that the amount is positive
    assert(amount >= 0, 'Amount must be non-negative');
  }
}

void main() {
  group('Transaction Data Validation', () {
    test('Valid transaction data', () {
      final transaction = TransactionObj(
        amount: 50.0,
        date: DateTime(2024, 11, 1),
        description: 'Groceries',
      );

      expect(transaction.amount, 50.0);
      expect(transaction.description, 'Groceries');
      expect(transaction.date, DateTime(2024, 11, 1));
      print('Valid transaction amount test successful');
    });

    test('Invalid transaction amount', () {
      expect(
        () => TransactionObj(
          amount: -20.0,
          date: DateTime(2024, 11, 1),
          description: 'Invalid Amount',
        ),
        throwsA(isA<AssertionError>()),
      );
      print('Invalid transaction amount test successful');
    });
  });
}
