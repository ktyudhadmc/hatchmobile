import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/constants/api_endpoints.dart';
import 'package:hatchmobile/core/network/auth_events.dart';
import 'package:hatchmobile/core/network/dio_client.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// Fakes the network layer under [Dio] so requests never actually go out —
/// every request gets back the fixed [statusCode] this is built with.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode);

  final int statusCode;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  late ProviderContainer container;

  setUp(() {
    final storage = _MockSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
  });

  test(
    'a 401 from a regular endpoint broadcasts on unauthorizedEventProvider',
    () async {
      final dio = container.read(dioProvider)
        ..httpClientAdapter = _StubAdapter(401);
      final events = container.read(unauthorizedEventProvider).stream;

      final emitted = expectLater(events, emits(anything));

      await expectLater(
        dio.get<void>(ApiEndpoints.profile),
        throwsA(isA<DioException>()),
      );

      await emitted;
    },
  );

  test('a 401 from the login endpoint does not broadcast', () async {
    final dio = container.read(dioProvider)
      ..httpClientAdapter = _StubAdapter(401);
    final events = container.read(unauthorizedEventProvider).stream;

    var wasEmitted = false;
    final subscription = events.listen((_) => wasEmitted = true);
    addTearDown(subscription.cancel);

    await expectLater(
      dio.post<void>(
        ApiEndpoints.login,
        data: {'username': 'budi', 'password': 'wrong'},
      ),
      throwsA(isA<DioException>()),
    );
    // Give any (wrongly) scheduled event a chance to land before asserting
    // it didn't.
    await Future<void>.delayed(Duration.zero);

    expect(wasEmitted, isFalse);
  });

  test('a non-401 error does not broadcast', () async {
    final dio = container.read(dioProvider)
      ..httpClientAdapter = _StubAdapter(500);
    final events = container.read(unauthorizedEventProvider).stream;

    var wasEmitted = false;
    final subscription = events.listen((_) => wasEmitted = true);
    addTearDown(subscription.cancel);

    await expectLater(
      dio.get<void>(ApiEndpoints.profile),
      throwsA(isA<DioException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(wasEmitted, isFalse);
  });
}
