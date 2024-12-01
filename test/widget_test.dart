import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/main.dart'; // Ensure this path is correct

void main() {
  testWidgets('Budget Buddy app loads correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(
        MyApp()); // Replace MyApp with the name of your main widget if different

    // Verify if the main widget of the app loads properly.
    expect(find.byType(MyApp), findsOneWidget);

    // Check if the title or some key text exists on the home screen.
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
