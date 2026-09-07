import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/core/errors/app_exception.dart';
import 'package:hatchmobile/features/auth/presentation/pages/login_page.dart';

void main() {
  group('loginErrorMessage', () {
    test('maps UnauthorizedException to a generic prompt', () {
      expect(
        loginErrorMessage(const UnauthorizedException('Sesi telah berakhir')),
        'Please check your input',
      );
    });

    test('maps BadRequestException to a generic prompt', () {
      expect(
        loginErrorMessage(const BadRequestException('Permintaan tidak valid')),
        'Please check your input',
      );
    });

    test('maps ValidationException to a generic prompt', () {
      expect(
        loginErrorMessage(ValidationException.fromResponseData({'errors': {}})),
        'Please check your input',
      );
    });

    test('keeps the original message for NetworkException', () {
      expect(
        loginErrorMessage(const NetworkException('Tidak ada koneksi internet')),
        'Tidak ada koneksi internet',
      );
    });

    test('keeps the original message for ServerException', () {
      expect(
        loginErrorMessage(const ServerException('Terjadi kesalahan pada server')),
        'Terjadi kesalahan pada server',
      );
    });

    test('falls back to toString for non-AppException errors', () {
      final error = Exception('boom');
      expect(loginErrorMessage(error), error.toString());
    });
  });
}
