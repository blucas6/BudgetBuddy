import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/transactionswidget.dart';
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/services/transaction.dart';

/// Fake implementation of Datadistributer
class FakeDatadistributer implements Datadistributer {
  @override
  Future<List<TransactionObj>> get allTransactions async {
    // Return fake transaction data
    return [
      TransactionObj(
        id: 1,
        year: '2023',
        month: 'January',
        amount: 150.0,
        tags: ['Groceries'],
        date: DateTime.parse('2023-01-10'),
      ),
      TransactionObj(
        id: 2,
        year: '2023',
        month: 'February',
        amount: 200.0,
        tags: ['Rent'],
        date: DateTime.parse('2023-02-15'),
      ),
      TransactionObj(
        id: 3,
        year: '2023',
        month: 'March',
        amount: 100.0,
        tags: ['Utilities'],
        date: DateTime.parse('2023-03-20'),
      ),
    ];
  }

  @override
  Future<void> updateData(int id, String column, String value) async {
    // No-op for testing
  }

  // Add other Datadistributer methods if needed
}

void main() {
  group('TransactionWidget Tests', () {
    late FakeDatadistributer fakeDatadistributer;

    setUp(() {
      // Initialize the fake datadistributer
      fakeDatadistributer = FakeDatadistributer();
    });

    testWidgets('Renders transaction headers and rows',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionWidget(datadistributer: fakeDatadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify headers are rendered
      expect(find.text('id'), findsOneWidget);
      expect(find.text('year'), findsOneWidget);
      expect(find.text('month'), findsOneWidget);
      expect(find.text('amount'), findsOneWidget);

      // Verify transactions are rendered
      expect(find.text('1'), findsOneWidget); // First transaction ID
      expect(find.text('January'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);

      expect(find.text('2'), findsOneWidget); // Second transaction ID
      expect(find.text('February'), findsOneWidget);
      expect(find.text('200.0'), findsOneWidget);

      expect(find.text('3'), findsOneWidget); // Third transaction ID
      expect(find.text('March'), findsOneWidget);
      expect(find.text('100.0'), findsOneWidget);
    });

    testWidgets('Applies filters correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionWidget(datadistributer: fakeDatadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      final state =
          tester.state<TransactionWidgetState>(find.byType(TransactionWidget));

      // Apply a filter for February 2023
      state.applyFilters('2023', 'February');
      await tester.pumpAndSettle();

      // Verify only filtered transactions are displayed
      expect(find.text('1'), findsNothing); // January should not be displayed
      expect(find.text('3'), findsNothing); // March should not be displayed
      expect(find.text('2'), findsOneWidget); // February should be displayed
      expect(find.text('February'), findsOneWidget);
      expect(find.text('200.0'), findsOneWidget);
    });

    testWidgets('Sorts columns correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionWidget(datadistributer: fakeDatadistributer),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      final state =
          tester.state<TransactionWidgetState>(find.byType(TransactionWidget));

      // Sort the "amount" column (index 3)
      state.sortMe(3);
      await tester.pumpAndSettle();

      // Verify transactions are sorted by amount (highest to lowest)
      expect(find.text('200.0'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('100.0'), findsOneWidget);

      // Reverse sort the "amount" column
      state.sortMe(3);
      await tester.pumpAndSettle();

      // Verify transactions are sorted by amount (lowest to highest)
      expect(find.text('100.0'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('200.0'), findsOneWidget);
    });
  });
}
