import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/errors/app_exception.dart';

void main() {
  group('AppException.toString', () {
    test('returns the message', () {
      expect(const AppException('Terjadi kesalahan').toString(), 'Terjadi kesalahan');
    });
  });

  group('subclass default messages', () {
    test('NetworkException', () {
      expect(const NetworkException().message, 'No internet connection');
    });

    test('UnauthorizedException', () {
      expect(const UnauthorizedException().message, 'Your session has expired, please sign in again');
    });

    test('NotFoundException', () {
      expect(const NotFoundException().message, 'Data not found');
    });

    test('ServerException', () {
      expect(const ServerException().message, 'A server error occurred');
    });
  });

  group('BadRequestException', () {
    test('carries the raw response data', () {
      final exception = BadRequestException('Bad input', {'field': 'value'});
      expect(exception.message, 'Bad input');
      expect(exception.data, {'field': 'value'});
    });
  });

  group('ValidationException.fromResponseData', () {
    test('parses a nested errors map into typed lists', () {
      final exception = ValidationException.fromResponseData({
        'errors': {
          'email': ['Email wajib diisi', 'Format email tidak valid'],
          'password': ['Password wajib diisi'],
        },
      });

      expect(exception.errors, {
        'email': ['Email wajib diisi', 'Format email tidak valid'],
        'password': ['Password wajib diisi'],
      });
      expect(exception.message, 'Validation failed');
    });

    test('uses the given message when provided', () {
      final exception = ValidationException.fromResponseData(
        {'errors': <String, dynamic>{}},
        'Custom message',
      );
      expect(exception.message, 'Custom message');
    });

    test('returns an empty errors map when data has no errors key', () {
      final exception = ValidationException.fromResponseData({'message': 'oops'});
      expect(exception.errors, isEmpty);
    });

    test('returns an empty errors map when data is not a map', () {
      final exception = ValidationException.fromResponseData('not a map');
      expect(exception.errors, isEmpty);
    });
  });
}
