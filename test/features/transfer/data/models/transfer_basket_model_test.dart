import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/transfer/data/models/transfer_basket_model.dart';

void main() {
  // Shape taken directly from the backend's GET response sample.
  final json = {
    'id': 1,
    'basket_code': 'A0001',
    'grades': [
      {'id': 1, 'grade': 'A', 'quantity': 1000, 'received_quantity': 1000},
    ],
    'transfer': {
      'id': 1,
      'transfer_code': '15082024TE0002',
      'transfer_date': '2024-01-15',
      'branch': {'id': 1, 'name': 'Jabung'},
    },
  };

  group('TransferBasketModel.fromJson', () {
    test('parses basket-level fields', () {
      final basket = TransferBasketModel.fromJson(json);

      expect(basket.id, 1);
      expect(basket.basketCode, 'A0001');
    });

    test('parses the grades list', () {
      final basket = TransferBasketModel.fromJson(json);

      expect(basket.grades, hasLength(1));
      expect(basket.grades.single.id, 1);
      expect(basket.grades.single.grade, 'A');
      expect(basket.grades.single.quantity, 1000);
      expect(basket.grades.single.receivedQuantity, 1000);
    });

    test('parses multiple grades', () {
      final multiGradeJson = {
        ...json,
        'grades': [
          {'id': 1, 'grade': 'A', 'quantity': 120, 'received_quantity': 120},
          {'id': 2, 'grade': 'B', 'quantity': 45, 'received_quantity': 45},
        ],
      };

      final basket = TransferBasketModel.fromJson(multiGradeJson);

      expect(basket.grades, hasLength(2));
      expect(basket.grades.map((g) => g.id), [1, 2]);
    });

    test('parses the nested transfer and branch', () {
      final basket = TransferBasketModel.fromJson(json);

      expect(basket.transfer.id, 1);
      expect(basket.transfer.transferCode, '15082024TE0002');
      expect(basket.transfer.transferDate, DateTime.parse('2024-01-15'));
      expect(basket.transfer.branch, 'Jabung');
    });
  });
}
