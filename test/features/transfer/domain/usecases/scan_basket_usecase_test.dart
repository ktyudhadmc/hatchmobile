import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_basket.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_branch.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_grade.dart';
import 'package:hatchmobile/features/transfer/domain/entities/transfer_info.dart';
import 'package:hatchmobile/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:hatchmobile/features/transfer/domain/usecases/scan_basket_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransferRepository extends Mock implements TransferRepository {}

TransferBasket _basket() {
  return TransferBasket(
    id: 1,
    basketCode: 'A0001',
    grades: const [TransferGrade(id: 1, grade: 'A', quantity: 1000, receivedQuantity: 1000)],
    transfer: TransferInfo(
      id: 1,
      transferCode: '15082024TE0002',
      transferDate: DateTime(2024, 1, 15),
      branch: const TransferBranch(id: 1, name: 'Jabung'),
    ),
  );
}

void main() {
  test('delegates to TransferRepository.getBasketByCode with the scanned code', () async {
    final repository = _MockTransferRepository();
    final basket = _basket();
    when(() => repository.getBasketByCode('A0001')).thenAnswer((_) async => basket);
    final usecase = ScanBasketUsecase(repository);

    final result = await usecase('A0001');

    expect(result, basket);
    verify(() => repository.getBasketByCode('A0001')).called(1);
  });
}
