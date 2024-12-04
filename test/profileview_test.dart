//profile view
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/widgets/profileview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocking Datadistributer using Mock from mocktail
class MockDatadistributer extends Mock implements Datadistributer {}

void main() {
  group('ProfileView Tests', () {
    late MockDatadistributer mockDatadistributer;

    setUp(() {
      mockDatadistributer = MockDatadistributer();
    });

    testWidgets('ProfileView displays profile data correctly',
        (WidgetTester tester) async {
      // Mock the response from loadProfile
      when(() => mockDatadistributer.loadProfile()).thenAnswer((_) async => {
            'totalspending': 200.0,
            'totalincome': 1000.0,
            'totalassets': 800.0,
            'totalsavings': 800.0,
          });

      // Mock ensureInitialized to resolve without issues
      when(() => mockDatadistributer.ensureInitialized())
          .thenAnswer((_) async => {});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileView(datadistributer: mockDatadistributer),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify the widget displays the correct data
      expect(find.text('My Profile Summary'), findsOneWidget);
      expect(find.text('Total Spending: \t\$200.00'), findsOneWidget);
      expect(find.text('Total Income: \t\$1000.00'), findsOneWidget);
      expect(find.text('Total Savings: \t\$800.00'), findsOneWidget);
      expect(find.text('Net Worth: \t\$800.00'), findsOneWidget);
    });

    testWidgets('ProfileView shows initial empty data before loading',
        (WidgetTester tester) async {
      // Mock the response from loadProfile with an empty profile
      when(() => mockDatadistributer.loadProfile()).thenAnswer((_) async => {
            'totalspending': 0.0,
            'totalincome': 0.0,
            'totalsavings': 0.0,
            'totalassets': 0.0,
          });

      // Mock ensureInitialized to resolve without issues
      when(() => mockDatadistributer.ensureInitialized())
          .thenAnswer((_) async => {});

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileView(datadistributer: mockDatadistributer),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('My Profile Summary'), findsOneWidget);
      expect(find.text('Total Spending: \t\$0.00'), findsOneWidget);
      expect(find.text('Total Income: \t\$0.00'), findsOneWidget);
      expect(find.text('Total Savings: \t\$0.00'), findsOneWidget);
      expect(find.text('Net Worth: \t\$0.00'), findsOneWidget);
    });
  });
}
