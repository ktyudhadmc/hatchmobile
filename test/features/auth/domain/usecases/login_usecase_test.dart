import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/domain/entities/user.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';
import 'package:hatchmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:hatchmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = User(
  id: 1,
  name: 'Budi',
  role: UserRole(id: 1, name: 'Admin'),
  hatchery: UserHatchery(id: 1, name: 'Hatchery A'),
);

void main() {
  late _MockAuthRepository repository;
  late LoginUsecase usecase;

  setUp(() {
    repository = _MockAuthRepository();
    usecase = LoginUsecase(repository);
  });

  test('delegates to AuthRepository.login with the given credentials', () async {
    when(() => repository.login(username: 'budi', password: 'secret'))
        .thenAnswer((_) async => _user);

    final result = await usecase(username: 'budi', password: 'secret');

    expect(result, _user);
    verify(() => repository.login(username: 'budi', password: 'secret')).called(1);
  });

  test('propagates errors thrown by the repository', () async {
    when(() => repository.login(username: any(named: 'username'), password: any(named: 'password')))
        .thenThrow(Exception('invalid credentials'));

    expect(
      () => usecase(username: 'budi', password: 'wrong'),
      throwsA(isA<Exception>()),
    );
  });
}
