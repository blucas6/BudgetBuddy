//editmenuwidget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/editmenuwidget.dart';

void main() {
  group('EditMenuWidget', () {
    testWidgets('Displays dropdown and delete button',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditMenuWidget(),
          ),
        ),
      );

      // Verify the title text
      expect(find.text('Add a tag'), findsOneWidget);

      // Verify the dropdown button
      expect(find.byType(DropdownButton<String>), findsOneWidget);

      // Verify the delete button
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // Verify the "Close" button
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Allows selecting a tag from the dropdown',
        (WidgetTester tester) async {
      String? returnedValue;

      // Wrap the widget in a MaterialApp and pass a callback to capture the return value
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedValue = await showDialog<String>(
                    context: context,
                    builder: (context) => EditMenuWidget(),
                  );
                },
                child: Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dropdown interaction
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select a tag from the dropdown
      await tester.tap(find.text('Rent').last);
      await tester.pumpAndSettle();

      // Verify the returned value
      expect(returnedValue, 'Rent');
    });

    testWidgets('Returns special value when delete button is pressed',
        (WidgetTester tester) async {
      String? returnedValue;

      // Wrap the widget in a MaterialApp and pass a callback to capture the return value
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedValue = await showDialog<String>(
                    context: context,
                    builder: (context) => EditMenuWidget(),
                  );
                },
                child: Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Verify the returned value
      expect(returnedValue, '_delete_');
    });

    testWidgets('Closes dialog without returning when Close button is pressed',
        (WidgetTester tester) async {
      String? returnedValue;

      // Wrap the widget in a MaterialApp and pass a callback to capture the return value
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedValue = await showDialog<String>(
                    context: context,
                    builder: (context) => EditMenuWidget(),
                  );
                },
                child: Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap the Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify the returned value
      expect(returnedValue, isNull);
    });
  });
}
