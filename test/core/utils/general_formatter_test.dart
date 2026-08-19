import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/utils/general_formatter.dart';

void main() {
  group('initialFormatter', () {
    test('returns first+last initials for a full name', () {
      expect(initialFormatter('Budi Santoso'), 'BS');
    });

    test('returns single initial for a single-word name', () {
      expect(initialFormatter('Budi'), 'B');
    });

    test('collapses extra whitespace between words', () {
      expect(initialFormatter('  Budi   Santoso  '), 'BS');
    });

    test('returns empty string for empty input', () {
      expect(initialFormatter(''), '');
    });

    test('uses first two words when name has more than two parts', () {
      expect(initialFormatter('Budi Andi Santoso'), 'BS');
    });
  });

  group('generateLocalId', () {
    test('generates a non-empty uuid-shaped string', () {
      final id = generateLocalId();
      expect(id, isNotEmpty);
      expect(RegExp(r'^[0-9a-f-]{36}$').hasMatch(id), isTrue);
    });

    test('generates different ids on each call', () {
      expect(generateLocalId(), isNot(generateLocalId()));
    });
  });

  group('parseDouble', () {
    test('returns null for null', () {
      expect(parseDouble(null), isNull);
    });

    test('passes through a double', () {
      expect(parseDouble(3.5), 3.5);
    });

    test('converts an int', () {
      expect(parseDouble(3), 3.0);
    });

    test('parses a numeric string', () {
      expect(parseDouble('3.5'), 3.5);
    });

    test('returns null for a non-numeric string', () {
      expect(parseDouble('abc'), isNull);
    });

    test('returns null for an unsupported type', () {
      expect(parseDouble(true), isNull);
    });
  });
}
