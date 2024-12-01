import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/widgets/account_bar.dart';
import 'package:budgetbuddy/services/database_service.dart';

void main() {
  late DatabaseService databaseService;

  setUp(() async {
    // Initialize the database service and clear previous data for a clean state
    databaseService = DatabaseService();
    await databaseService.loadDatabase();
    //await databaseService.clearAccounts(); // Clear account data before each test
  });

  tearDown(() async {
    // Clean up after tests to ensure isolation
    //await databaseService.clearAccounts();
  });

  Widget createWidgetUnderTest(void Function() newDataTrigger) {
    return MaterialApp(
      home: Scaffold(
        body: AccountBar(
          newDataTrigger: newDataTrigger,
          datadistributer:
             // databaseService, // Pass the actual database service or data provider
        ),
      ),
    );
  }

  testWidgets('AccountBar displays accounts from the database',
      (WidgetTester tester) async {
    // Arrange: Add test accounts to the database
    await databaseService.addAccount('Account 1');
    await databaseService.addAccount('Account 2');

    // Act: Render the widget
    await tester.pumpWidget(createWidgetUnderTest(() {}));
    await tester.pumpAndSettle();

    // Assert: Verify that the accounts are displayed
    expect(find.text('Account 1'), findsOneWidget);
    expect(find.text('Account 2'), findsOneWidget);
  });

  testWidgets('AccountBar adds a new account and refreshes the list',
      (WidgetTester tester) async {
    // Arrange: Ensure the database starts empty
    expect(await databaseService.getAllAccounts(), isEmpty);

    // Act: Render the widget
    bool dataReloaded = false;
    await tester.pumpWidget(createWidgetUnderTest(() {
      dataReloaded = true; // Trigger callback for data reload
    }));

    // Simulate adding a new account
    await databaseService.addAccount('New Account');
    await tester.pumpAndSettle();

    // Assert: Verify that the new account is displayed
    expect(find.text('New Account'), findsOneWidget);
    expect(dataReloaded, isTrue);
  });

  testWidgets('AccountBar shows error when adding an invalid account',
      (WidgetTester tester) async {
    // Act: Render the widget and simulate an invalid account addition
    await tester.pumpWidget(createWidgetUnderTest(() {}));
    await databaseService.addAccount(''); // Invalid account (empty name)
    await tester.pumpAndSettle();

    // Assert: Verify that no empty account appears in the list
    expect(find.text(''), findsNothing);

    // Check if an error dialog or appropriate message is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Unsupported account type!'), findsOneWidget);
  });
}
