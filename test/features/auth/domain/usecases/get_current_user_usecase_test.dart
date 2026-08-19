import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/domain/entities/user.dart';
import 'package:hatchmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:hatchmobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late GetCurrentUserUsecase usecase;

  setUp(() {
    repository = _MockAuthRepository();
    usecase = GetCurrentUserUsecase(repository);
  });

  test('returns the cached user when one exists', () async {
    const user = User(id: 1, name: 'Budi');
    when(() => repository.getCachedUser()).thenAnswer((_) async => user);

    expect(await usecase(), user);
  });

  test('returns null when there is no cached session', () async {
    when(() => repository.getCachedUser()).thenAnswer((_) async => null);

    expect(await usecase(), isNull);
  });
}
