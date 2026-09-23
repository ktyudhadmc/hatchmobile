import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/network/auth_events.dart';
import 'package:hatchmobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hatchmobile/features/auth/domain/entities/user.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';
import 'package:hatchmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:hatchmobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late ProviderContainer container;

  const user = User(
    id: 1,
    name: 'Budi',
    role: UserRole(id: 1, name: 'Admin'),
    hatchery: UserHatchery(id: 1, name: 'Hatchery A'),
  );

  setUp(() {
    repository = _MockAuthRepository();
    // Constructor kicks off restoreSession(); stub it up front so that
    // fire-and-forget call has something sane to resolve to.
    when(() => repository.getCachedUser()).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('restoreSession resolves to the cached user', () async {
    when(() => repository.getCachedUser()).thenAnswer((_) async => user);

    await container.read(authProvider.notifier).restoreSession();

    expect(container.read(authProvider).value, user);
  });

  test('restoreSession resolves to null when there is no session', () async {
    await container.read(authProvider.notifier).restoreSession();

    expect(container.read(authProvider).value, isNull);
    expect(container.read(isAuthenticatedProvider), isFalse);
  });

  test('login success updates state to the logged-in user', () async {
    when(() => repository.login(username: 'budi', password: 'secret'))
        .thenAnswer((_) async => user);

    await container.read(authProvider.notifier).login(username: 'budi', password: 'secret');

    expect(container.read(authProvider).value, user);
    expect(container.read(isAuthenticatedProvider), isTrue);
  });

  test('login failure surfaces the error without throwing', () async {
    when(() => repository.login(username: any(named: 'username'), password: any(named: 'password')))
        .thenThrow(Exception('invalid credentials'));

    await container.read(authProvider.notifier).login(username: 'budi', password: 'wrong');

    expect(container.read(authProvider).hasError, isTrue);
    expect(container.read(isAuthenticatedProvider), isFalse);
  });

  test('logout clears the session and state', () async {
    when(() => repository.login(username: 'budi', password: 'secret'))
        .thenAnswer((_) async => user);
    when(() => repository.logout()).thenAnswer((_) async {});

    final notifier = container.read(authProvider.notifier);
    await notifier.login(username: 'budi', password: 'secret');
    expect(container.read(authProvider).value, user);

    await notifier.logout();

    expect(container.read(authProvider).value, isNull);
    verify(() => repository.logout()).called(1);
  });

  group('forceLogout', () {
    test('clears the local session and state without hitting logout()', () async {
      when(() => repository.login(username: 'budi', password: 'secret'))
          .thenAnswer((_) async => user);
      when(() => repository.clearSession()).thenAnswer((_) async {});

      final notifier = container.read(authProvider.notifier);
      await notifier.login(username: 'budi', password: 'secret');
      expect(container.read(authProvider).value, user);

      await notifier.forceLogout();

      expect(container.read(authProvider).value, isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      verify(() => repository.clearSession()).called(1);
      verifyNever(() => repository.logout());
    });

    test('is a no-op when there is no logged-in user', () async {
      when(() => repository.clearSession()).thenAnswer((_) async {});

      final notifier = container.read(authProvider.notifier);
      await notifier.restoreSession();
      expect(container.read(authProvider).value, isNull);

      await notifier.forceLogout();

      verifyNever(() => repository.clearSession());
    });

    test(
      'a 401 broadcast on unauthorizedEventProvider triggers forceLogout',
      () async {
        when(() => repository.login(username: 'budi', password: 'secret'))
            .thenAnswer((_) async => user);
        when(() => repository.clearSession()).thenAnswer((_) async {});

        // Read authProvider first so its internal subscription to
        // unauthorizedEventProvider is actually set up before we emit.
        final notifier = container.read(authProvider.notifier);
        await notifier.login(username: 'budi', password: 'secret');
        expect(container.read(authProvider).value, user);

        container.read(unauthorizedEventProvider).add(null);
        // Let the stream's listener callback run.
        await Future<void>.delayed(Duration.zero);

        expect(container.read(authProvider).value, isNull);
        verify(() => repository.clearSession()).called(1);
      },
    );
  });
}
