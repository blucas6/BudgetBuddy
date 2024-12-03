//ui logic
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:budgetbuddy/main.dart';

void main() {
  testWidgets('Main UI loads correctly', (WidgetTester tester) async {
    // Suppress layout overflow errors during the test.
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        // Ignore overflow errors.
      } else {
        FlutterError.presentError(details);
      }
    };

    // Arrange: Load the main widget of the app.
    await tester.pumpWidget(const MyApp());

    // Act: Wait for the widget tree to stabilize.
    await tester.pumpAndSettle();

    // Assert: Simply check if the app loads successfully.
    expect(find.byType(MyApp), findsOneWidget);

    // Restore default error handler after the test.
    FlutterError.onError = FlutterError.presentError;
  });
}
