import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/widgets/filterwidget.dart';

class MockDatadistributer implements Datadistributer {
  @override
  Future<Map<String, dynamic>> getTotalDateRange() async {
    return {
      '2023': ['January', 'February', 'March'],
      '2022': ['October', 'November', 'December'],
    };
  }

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<List<String>> loadAccountList() async {
    return ['Account 1', 'Account 2'];
  }

  @override
  Future<void> addTransactionFileToDatabase(dynamic transactionFile) async {}

  @override
  Future<void> loadPipeline() async {}

  @override
  Future<void> deleteTransaction(String transactionId) async {}

  @override
  Future<void> updateTransaction(
      String transactionId, Map<String, dynamic> updatedData) async {}

  @override
  Future<List<Map<String, dynamic>>> loadTransactions(
      String? year, String? month) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> filterTransactions(
      Map<String, dynamic> filters) async {
    return [];
  }

  @override
  Future<void> clearDatabase() async {}
}

void main() {
  group('FilterWidget Tests', () {
    late MockDatadistributer mockDatadistributer;

    setUp(() {
      mockDatadistributer = MockDatadistributer();
    });

    testWidgets('Displays dropdowns and initializes correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterWidget(
            datadistributer: mockDatadistributer,
            newFilterTrigger: (_, __) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Select a year'), findsOneWidget);
      expect(find.text('Select a month'), findsOneWidget);
    });

    testWidgets('Allows selecting a year and updates months accordingly',
        (WidgetTester tester) async {
      String? selectedYear;
      String? selectedMonth;

      await tester.pumpWidget(
        MaterialApp(
          home: FilterWidget(
            datadistributer: mockDatadistributer,
            newFilterTrigger: (year, month) {
              selectedYear = year;
              selectedMonth = month;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Select a year'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023').last);
      await tester.pumpAndSettle();

      expect(selectedYear, '2023');
      expect(selectedMonth, isNull);

      await tester.tap(find.text('Select a month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('February').last);
      await tester.pumpAndSettle();

      expect(selectedYear, '2023');
      expect(selectedMonth, 'February');
    });
  });
}
