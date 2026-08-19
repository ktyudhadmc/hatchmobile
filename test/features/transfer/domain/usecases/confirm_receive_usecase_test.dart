import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:hatchmobile/features/transfer/domain/usecases/confirm_receive_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockTransferRepository extends Mock implements TransferRepository {}

void main() {
  test('delegates to TransferRepository.confirmReceive with the given payload', () async {
    final repository = _MockTransferRepository();
    when(
      () => repository.confirmReceive(
        transferId: any(named: 'transferId'),
        transferBasketId: any(named: 'transferBasketId'),
        grades: any(named: 'grades'),
      ),
    ).thenAnswer((_) async {});
    final usecase = ConfirmReceiveUsecase(repository);

    const grades = [(id: 1, receivedQuantity: 120), (id: 2, receivedQuantity: 45)];

    await usecase(transferId: 1, transferBasketId: 1, grades: grades);

    verify(
      () => repository.confirmReceive(transferId: 1, transferBasketId: 1, grades: grades),
    ).called(1);
  });
}
