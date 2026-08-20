import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/transfer/data/repositories/transfer_repository_impl.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_basket.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_grade.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_info.dart';
import 'package:hatchmobile/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:hatchmobile/features/transfer/presentation/providers/transfer_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransferRepository extends Mock implements TransferRepository {}

TransferBasket _basket() {
  return TransferBasket(
    id: 1,
    basketCode: 'A0001',
    grades: const [
      TransferGrade(id: 1, grade: 'A', quantity: 1000, receivedQuantity: 1000),
    ],
    transfer: TransferInfo(
      id: 1,
      transferCode: '15082024TE0002',
      transferDate: DateTime(2024, 1, 15),
      productionDate: DateTime(2024, 1, 1),
      branch: 'Jabung',
    ),
  );
}

void main() {
  late _MockTransferRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _MockTransferRepository();
    container = ProviderContainer(
      overrides: [transferRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  group('scanBasketProvider', () {
    test('starts as data(null) before any scan', () {
      expect(container.read(scanBasketProvider).value, isNull);
    });

    test('scan success populates the basket', () async {
      final basket = _basket();
      when(
        () => repository.getBasketByCode('A0001'),
      ).thenAnswer((_) async => basket);

      await container.read(scanBasketProvider.notifier).scan('A0001');

      expect(container.read(scanBasketProvider).value, basket);
    });

    test('scan failure surfaces the error', () async {
      when(
        () => repository.getBasketByCode(any()),
      ).thenThrow(Exception('not found'));

      await container.read(scanBasketProvider.notifier).scan('UNKNOWN');

      expect(container.read(scanBasketProvider).hasError, isTrue);
    });
  });

  group('confirmReceiveProvider', () {
    test('confirm success resolves without error', () async {
      when(
        () => repository.confirmReceive(
          transferId: any(named: 'transferId'),
          transferBasketId: any(named: 'transferBasketId'),
          grades: any(named: 'grades'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(confirmReceiveProvider.notifier)
          .confirm(
            transferId: 1,
            transferBasketId: 1,
            grades: const [(id: 1, receivedQuantity: 120)],
          );

      expect(container.read(confirmReceiveProvider).hasError, isFalse);
    });

    test('confirm failure surfaces the error', () async {
      when(
        () => repository.confirmReceive(
          transferId: any(named: 'transferId'),
          transferBasketId: any(named: 'transferBasketId'),
          grades: any(named: 'grades'),
        ),
      ).thenThrow(Exception('server error'));

      await container
          .read(confirmReceiveProvider.notifier)
          .confirm(
            transferId: 1,
            transferBasketId: 1,
            grades: const [(id: 1, receivedQuantity: 120)],
          );

      expect(container.read(confirmReceiveProvider).hasError, isTrue);
    });
  });
}
