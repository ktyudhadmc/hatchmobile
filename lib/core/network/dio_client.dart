import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/device_info_helper.dart';
import 'connectivity_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      followRedirects: true,
      maxRedirects: 3,
      headers: {'Accept': 'application/json'},
    ),
  );

  final storage = ref.watch(secureStorageProvider);
  final connectivity = ref.watch(connectivityServiceProvider);

  dio.interceptors.addAll([
    _AuthInterceptor(storage),
    _ErrorInterceptor(connectivity),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['x-platform'] = DeviceInfoHelper.instance.platform;
    options.headers['x-app-version'] = DeviceInfoHelper.instance.appVersion;
    options.headers['x-device-id'] = DeviceInfoHelper.instance.deviceId;
    options.headers['user-agent'] = DeviceInfoHelper.instance.userAgent;

    handler.next(options);
  }
}

/// Converts every [DioException] into an [AppException] subclass so the
/// rest of the app never has to deal with Dio-specific error types.
class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor(this._connectivity);

  final ConnectivityService _connectivity;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        handler.next(_wrap(err, await _networkOrServerException()));
        return;
      default:
        break;
    }

    if (response == null) {
      handler.next(_wrap(err, await _networkOrServerException()));
      return;
    }

    final data = response.data;
    final message = (data is Map && data['message'] is String)
        ? data['message'] as String
        : null;

    final AppException mapped = switch (response.statusCode ?? 0) {
      400 => BadRequestException(message ?? 'Invalid request', data),
      401 => UnauthorizedException(
        message ?? 'Your session has expired, please sign in again',
      ),
      403 => ForbiddenException(
        message ?? 'You do not have access to this resource',
      ),
      404 => NotFoundException(message ?? 'Data not found'),
      422 => ValidationException.fromResponseData(data, message),
      >= 500 => ServerException(message ?? 'A server error occurred'),
      _ => AppException(message ?? 'Something went wrong', data: data),
    };

    handler.next(_wrap(err, mapped));
  }

  /// Distinguishes a genuinely offline device from one that has a working
  /// network interface but simply failed to reach the server (timeout,
  /// DNS/TLS failure, server down, etc.), so the message shown to the user
  /// matches what's actually wrong.
  Future<AppException> _networkOrServerException() async {
    final hasNetworkInterface = await _connectivity.isConnected();
    return hasNetworkInterface
        ? const ServerUnreachableException()
        : const NetworkException();
  }

  DioException _wrap(DioException err, AppException exception) {
    return err.copyWith(error: exception);
  }
}
