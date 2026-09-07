import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/domain/entities/user.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';
import 'package:hatchmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:hatchmobile/features/auth/domain/usecases/get_current_user_usecase.dart';
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
  late GetCurrentUserUsecase usecase;

  setUp(() {
    repository = _MockAuthRepository();
    usecase = GetCurrentUserUsecase(repository);
  });

  test('returns the cached user when one exists', () async {
    when(() => repository.getCachedUser()).thenAnswer((_) async => _user);

    expect(await usecase(), _user);
  });

  test('returns null when there is no cached session', () async {
    when(() => repository.getCachedUser()).thenAnswer((_) async => null);

    expect(await usecase(), isNull);
  });
}
