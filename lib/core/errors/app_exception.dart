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
  const NetworkException([super.message = 'No internet connection']);
}

/// The device has a working network interface (Wi-Fi/data), but the
/// request itself failed to reach the server (timeout, DNS/TLS failure,
/// server down, etc.). Kept distinct from [NetworkException] so the
/// message shown to the user matches what's actually wrong instead of
/// always claiming there's no internet connection.
class ServerUnreachableException extends AppException {
  const ServerUnreachableException([
    super.message = 'Unable to reach the server. Please check your connection or try again later.',
  ]);
}

class BadRequestException extends AppException {
  const BadRequestException([super.message = 'Invalid request', dynamic data]) : super(data: data);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Your session has expired, please sign in again']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'You do not have access to this resource']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Data not found']);
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  ValidationException(this.errors, [String message = 'Validation failed']) : super(message, data: errors);

  factory ValidationException.fromResponseData(dynamic data, [String? message]) {
    final rawErrors = data is Map ? data['errors'] : null;
    final parsed = <String, List<String>>{};
    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        parsed[key.toString()] = (value as List).map((e) => e.toString()).toList();
      });
    }
    return ValidationException(parsed, message ?? 'Validation failed');
  }
}

class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Failed to load local data']);
}
