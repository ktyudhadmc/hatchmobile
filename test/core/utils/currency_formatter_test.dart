import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats a whole number with thousands separators', () {
      expect(CurrencyFormatter.format(10000), 'Rp 10.000');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.format(0), 'Rp 0');
    });

    test('rounds away decimal digits', () {
      expect(CurrencyFormatter.format(1500.75), 'Rp 1.501');
    });
  });
}
