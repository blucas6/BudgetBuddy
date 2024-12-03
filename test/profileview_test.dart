import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/profileview.dart';
import 'package:budgetbuddy/components/datadistributer.dart';

// Manual mock implementation of Datadistributer
class FakeDatadistributer implements Datadistributer {
  // The fake implementation returns pre-defined profile data
  @override
  Future<Map<String, double>> loadProfile() async {
    return {
      "totalspending": 1200.50,
      "totalincome": 4500.00,
      "totalassets": 25000.75,
    };
  }

  // If other methods of Datadistributer are required in the future, they can be added here
}

void main() {
  group('ProfileView Widget Tests', () {
    late FakeDatadistributer fakeDatadistributer;

    setUp(() {
      // Initialize the fake datadistributer
      fakeDatadistributer = FakeDatadistributer();
    });

    testWidgets('Renders initial profile summary', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileView(datadistributer: fakeDatadistributer),
          ),
        ),
      );

      // Verify the initial text is displayed (before data loads)
      expect(find.text('My Profile Summary'), findsOneWidget);
      expect(find.text('Total Spending: 0.00'), findsOneWidget);
      expect(find.text('Total Income: 0.00'), findsOneWidget);
      expect(find.text('Net Worth: 0.00'), findsOneWidget);
    });

    testWidgets('Updates profile data after loading',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileView(datadistributer: fakeDatadistributer),
          ),
        ),
      );

      // Wait for the async operation to complete
      await tester.pumpAndSettle();

      // Verify updated text is displayed with mocked profile data
      expect(find.text('My Profile Summary'), findsOneWidget);
      expect(find.text('Total Spending: 1200.50'), findsOneWidget);
      expect(find.text('Total Income: 4500.00'), findsOneWidget);
      expect(find.text('Net Worth: 25000.75'), findsOneWidget);
    });
  });
}
