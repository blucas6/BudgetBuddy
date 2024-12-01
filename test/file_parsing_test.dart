import 'package:flutter_test/flutter_test.dart';

void main() {
  group('File Parsing', () {
    test('Parse valid CSV file', () async {
      final data = await parseCSV('test_data.csv');

      expect(data.isNotEmpty, true);
      expect(data[0].description, 'Groceries'); // Example check for first row
    });

    test('Handle missing file', () async {
      expect(() async => await parseCSV('missing.csv'),
          throwsA(isA<FileNotFoundError>()));
    });

    test('Handle invalid CSV format', () async {
      expect(() async => await parseCSV('invalid_format.csv'),
          throwsA(isA<InvalidCSVFormatError>()));
    });

    test('Parse empty CSV file', () async {
      final data = await parseCSV('empty.csv');

      expect(data.isEmpty, true);
    });

    test('Parse large CSV file', () async {
      final data = await parseCSV('large_data.csv');

      expect(
          data.length, greaterThan(1000)); // Example check for number of rows
    });
  });
}
