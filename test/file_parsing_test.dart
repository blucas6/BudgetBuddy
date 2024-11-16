//file parsng
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
  });
}
