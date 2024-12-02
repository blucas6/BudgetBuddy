import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/main.dart'; // Update the path to where MyApp is defined

void main() {
  testWidgets('Budget Buddy app loads correctly', (WidgetTester tester) async {
    // Wrap the app in a MaterialApp if MyApp doesn't handle it internally.
    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(), // Replace MyApp with the correct entry widget
      ),
    );

    // Verify if the main widget of the app loads properly.
    expect(find.byType(MyApp), findsOneWidget);

    // Check if the key text exists on the home screen.
    expect(find.text('Analysis'), findsOneWidget);

    // Check if the BottomNavigationBar items exist.
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.money), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);

    // Optionally, check if other text or icons are present.
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Total Expense'), findsOneWidget);
  });
}
