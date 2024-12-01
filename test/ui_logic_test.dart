import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/main.dart';
import 'package:flutter/material.dart';

void main() {
  debugPrint = (String? message, {int? wrapWidth}) => print(message ?? '');

  testWidgets('Add account button displays account',
      (WidgetTester tester) async {
    // Build the widget tree from the main app.
    await tester.pumpWidget(MyApp());

    // Find the add account button and tap it.
    final addButton = find.byKey(Key('addAccountButton')); // Updated key
    await tester.tap(addButton);

    // Trigger a frame to update the UI.
    await tester.pump();

    // Verify if the account is displayed in the list.
    expect(
        find.text('New Account'), findsOneWidget); // Adjust text if necessary
  });
}
