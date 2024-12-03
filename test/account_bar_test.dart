import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:file_picker/file_picker.dart';
import 'package:budgetbuddy/widgets/account_bar.dart';
import 'package:budgetbuddy/components/datadistributer.dart';
import 'package:budgetbuddy/components/transactionfile.dart';
import 'account_bar_test.mocks.dart';

// Generate mocks for the classes
@GenerateMocks([Datadistributer, TransactionFile])
void main() {
  late MockDatadistributer mockDatadistributer;

  setUp(() {
    mockDatadistributer = MockDatadistributer();

    // Use a custom mock for FilePicker
    FilePicker.platform = CustomMockFilePicker();
  });

  testWidgets('Handles addNewAccount function correctly',
      (WidgetTester tester) async {
    when(mockDatadistributer.loadAccountList())
        .thenAnswer((_) async => ['Account 1']);
    when(mockDatadistributer.addTransactionFileToDatabase(any))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(
      MaterialApp(
        home: AccountBar(
          newDataTrigger: () {},
          datadistributer: mockDatadistributer,
        ),
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Account 2'), findsOneWidget);
    verify(mockDatadistributer.addTransactionFileToDatabase(any)).called(1);
    verify(mockDatadistributer.loadAccountList()).called(2);
  });
}

// Custom mock implementation for FilePicker
class CustomMockFilePicker extends FilePicker {
  @override
  Future<FilePickerResult?> pickFiles({FileType type = FileType.any}) async {
    return FilePickerResult([
      PlatformFile(name: 'mockfile.csv', size: 1024, path: '/mockpath.csv'),
    ]);
  }
}
