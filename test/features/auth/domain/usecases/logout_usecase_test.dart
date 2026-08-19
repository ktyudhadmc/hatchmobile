import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:hatchmobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('delegates to AuthRepository.logout', () async {
    final repository = _MockAuthRepository();
    when(() => repository.logout()).thenAnswer((_) async {});
    final usecase = LogoutUsecase(repository);

    await usecase();

    verify(() => repository.logout()).called(1);
  });
}
