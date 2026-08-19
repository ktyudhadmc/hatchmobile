/// Base exception type for the app. Every error that crosses a repository
/// or use case boundary should surface as one of the subclasses below so
/// the presentation layer can branch on type instead of parsing messages.
class AppException implements Exception {
  final String message;
  final dynamic data;

  const AppException(this.message, {this.data});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Tidak ada koneksi internet']);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Permintaan tidak valid', dynamic data])
      : super(data: data);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sesi telah berakhir, silakan masuk kembali']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Anda tidak memiliki akses']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Data tidak ditemukan']);
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  ValidationException(this.errors, [String message = 'Validasi gagal'])
      : super(message, data: errors);

  factory ValidationException.fromResponseData(dynamic data, [String? message]) {
    final rawErrors = data is Map ? data['errors'] : null;
    final parsed = <String, List<String>>{};
    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        parsed[key.toString()] = (value as List).map((e) => e.toString()).toList();
      });
    }
    return ValidationException(parsed, message ?? 'Validasi gagal');
  }
}

class ServerException extends AppException {
  const ServerException([super.message = 'Terjadi kesalahan pada server']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Gagal mengambil data lokal']);
}
