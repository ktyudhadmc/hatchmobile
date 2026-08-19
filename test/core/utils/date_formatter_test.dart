import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.format', () {
    test('formats as dd/MM/yyyy', () {
      expect(DateFormatter.format(DateTime(2026, 1, 5)), '05/01/2026');
    });
  });

  group('DateFormatter.formatDateTime', () {
    test('formats as dd/MM/yyyy HH:mm', () {
      expect(DateFormatter.formatDateTime(DateTime(2026, 1, 5, 8, 3)), '05/01/2026 08:03');
    });
  });

  group('DateFormatter.toApiFormat', () {
    test('formats as yyyy-MM-dd', () {
      expect(DateFormatter.toApiFormat(DateTime(2026, 1, 5)), '2026-01-05');
    });
  });

  group('DateFormatter.tryParse', () {
    test('parses a valid ISO string', () {
      expect(DateFormatter.tryParse('2026-01-05'), DateTime.parse('2026-01-05'));
    });

    test('returns null for null input', () {
      expect(DateFormatter.tryParse(null), isNull);
    });

    test('returns null for empty input', () {
      expect(DateFormatter.tryParse(''), isNull);
    });

    test('returns null for garbage input', () {
      expect(DateFormatter.tryParse('not-a-date'), isNull);
    });
  });

  group('DateFormatter.relative', () {
    test('returns "Baru saja" for just now', () {
      expect(DateFormatter.relative(DateTime.now()), 'Baru saja');
    });

    test('returns minutes ago within the last hour', () {
      final date = DateTime.now().subtract(const Duration(minutes: 5));
      expect(DateFormatter.relative(date), '5 menit yang lalu');
    });

    test('returns hours ago within the last day', () {
      final date = DateTime.now().subtract(const Duration(hours: 3));
      expect(DateFormatter.relative(date), '3 jam yang lalu');
    });

    test('returns days ago within the last month', () {
      final date = DateTime.now().subtract(const Duration(days: 2));
      expect(DateFormatter.relative(date), '2 hari yang lalu');
    });

    test('falls back to formatted date beyond a month', () {
      final date = DateTime.now().subtract(const Duration(days: 40));
      expect(DateFormatter.relative(date), DateFormatter.format(date));
    });
  });
}
