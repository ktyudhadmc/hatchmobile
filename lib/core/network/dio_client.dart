import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/device_info_helper.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );

  final storage = ref.watch(secureStorageProvider);

  dio.interceptors.addAll([
    _AuthInterceptor(storage),
    _ErrorInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
});

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        handler.next(_wrap(err, const NetworkException()));
        return;
      default:
        break;
    }

    if (response == null) {
      handler.next(_wrap(err, const NetworkException()));
      return;
    }

    final data = response.data;
    final message = (data is Map && data['message'] is String) ? data['message'] as String : null;

    final AppException mapped = switch (response.statusCode ?? 0) {
      400 => BadRequestException(message ?? 'Permintaan tidak valid', data),
      401 => UnauthorizedException(message ?? 'Sesi telah berakhir, silakan masuk kembali'),
      403 => ForbiddenException(message ?? 'Anda tidak memiliki akses'),
      404 => NotFoundException(message ?? 'Data tidak ditemukan'),
      422 => ValidationException.fromResponseData(data, message),
      >= 500 => ServerException(message ?? 'Terjadi kesalahan pada server'),
      _ => AppException(message ?? 'Terjadi kesalahan', data: data),
    };

    handler.next(_wrap(err, mapped));
  }

  DioException _wrap(DioException err, AppException exception) {
    return err.copyWith(error: exception);
  }
}
