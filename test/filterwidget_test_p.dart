import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/widgets/filterwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocking Datadistributer using Mocktail
class MockDatadistributer extends Mock implements Datadistributer {}

void main() {
  group('FilterWidget Tests', () {
    late MockDatadistributer mockDatadistributer;

    setUp(() {
      mockDatadistributer = MockDatadistributer();
    });

    testWidgets('FilterWidget displays year and month dropdowns correctly',
        (WidgetTester tester) async {
      // Mock getTotalDateRange to return a sample date range
      when(() => mockDatadistributer.getTotalDateRange())
          .thenAnswer((_) async => {
                '2022': ['January', 'February'],
                '2023': ['March', 'April'],
              });

      String? selectedYear;
      String? selectedMonth;

      // Build the FilterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterWidget(
              datadistributer: mockDatadistributer,
              newFilterTrigger: (year, month) {
                selectedYear = year;
                selectedMonth = month;
              },
            ),
          ),
        ),
      );

      // Wait for the widget to fetch data
      await tester.pumpAndSettle();

      // Verify year dropdown is present
      expect(find.text('Select a year'), findsOneWidget);
      expect(find.byType(DropdownButton), findsWidgets);

      // Open year dropdown
      await tester.tap(find.text('Select a year'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify year options
      expect(find.text('2022'), findsOneWidget);
      expect(find.text('2023'), findsOneWidget);

      // Select a year
      await tester.tap(find.text('2022').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the month dropdown is updated
      expect(find.text('Select a month'), findsOneWidget);

      // Open month dropdown
      await tester.tap(find.text('Select a month'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify month options for the selected year
      expect(find.text('January'), findsOneWidget);
      expect(find.text('February'), findsOneWidget);

      // Select a month
      await tester.tap(find.text('January').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the newFilterTrigger callback was triggered correctly
      expect(selectedYear, equals('2022'));
      expect(selectedMonth, equals('January'));
    });

    testWidgets('FilterWidget resets month when a new year is selected',
        (WidgetTester tester) async {
      // Mock getTotalDateRange to return a sample date range
      when(() => mockDatadistributer.getTotalDateRange())
          .thenAnswer((_) async => {
                '2022': ['January', 'February'],
                '2023': ['March', 'April'],
              });

      String? selectedYear;
      String? selectedMonth;

      // Build the FilterWidget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterWidget(
              datadistributer: mockDatadistributer,
              newFilterTrigger: (year, month) {
                selectedYear = year;
                selectedMonth = month;
              },
            ),
          ),
        ),
      );

      // Wait for the widget to fetch data
      await tester.pumpAndSettle();

      // Select a year
      await tester.tap(find.text('Select a year'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2022').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Select a month
      await tester.tap(find.text('Select a month'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('January').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the newFilterTrigger callback was triggered
      expect(selectedYear, equals('2022'));
      expect(selectedMonth, equals('January'));

      // Change the year
      await tester.tap(find.text('2022'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify month is reset
      expect(selectedMonth, isNull);

      // Select a new month
      await tester.tap(find.text('Select a month'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('March').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify the newFilterTrigger callback was triggered with new values
      expect(selectedYear, equals('2023'));
      expect(selectedMonth, equals('March'));
    });
  });
}
