import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/dev_log.dart';
import '../utils/device_info_helper.dart';
import 'auth_events.dart';
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
    _UnauthorizedInterceptor(ref.read(unauthorizedEventProvider)),
    _ErrorInterceptor(connectivity),
    _DevLogInterceptor(),
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

/// Signals [unauthorizedEventProvider] whenever the server rejects an
/// already-authenticated request with 401, so the auth feature can force a
/// logout. Excludes the login endpoint itself — a 401 there just means
/// wrong credentials, not an expired session.
class _UnauthorizedInterceptor extends Interceptor {
  _UnauthorizedInterceptor(this._events);

  final StreamController<void> _events;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isLoginRequest = err.requestOptions.path == ApiEndpoints.login;
    if (err.response?.statusCode == 401 && !isLoginRequest) {
      _events.add(null);
    }
    handler.next(err);
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

/// Mirrors every request/response/error into [DevLog] under [DevLogTag.api]
/// so the developer log page (see DevLogPage) shows exactly what was sent
/// and what came back, without each usecase having to log it by hand.
/// Placed after [_ErrorInterceptor] so a failed call's `onError` already
/// carries the mapped [AppException] message rather than the raw Dio one.
class _DevLogInterceptor extends Interceptor {
  static const _maxBodyLength = 800;

  String _label(RequestOptions options) =>
      '${options.method} ${options.uri.path}';

  String? _encode(Object? data) {
    if (data == null) return null;
    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      return pretty.length > _maxBodyLength
          ? '${pretty.substring(0, _maxBodyLength)}\n...(truncated)'
          : pretty;
    } catch (_) {
      final raw = data.toString();
      return raw.length > _maxBodyLength
          ? '${raw.substring(0, _maxBodyLength)}...(truncated)'
          : raw;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final parts = [
      if (options.queryParameters.isNotEmpty)
        'Query: ${_encode(options.queryParameters)}',
      if (options.data != null) 'Body: ${_encode(options.data)}',
    ];
    DevLog.instance.add(
      DevLogTag.api,
      '→ ${_label(options)}',
      detail: parts.isEmpty ? null : parts.join('\n'),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    DevLog.instance.add(
      DevLogTag.api,
      '← ${_label(response.requestOptions)} (${response.statusCode})',
      level: DevLogLevel.success,
      detail: _encode(response.data),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final appError = err.error;
    final reason = appError is AppException
        ? appError.message
        : err.message ?? 'Unknown error';

    DevLog.instance.add(
      DevLogTag.api,
      '✕ ${_label(err.requestOptions)} (${statusCode ?? 'no response'})',
      level: DevLogLevel.error,
      detail: 'Error: $reason'
          '${err.response?.data != null ? '\nResponse: ${_encode(err.response?.data)}' : ''}',
    );
    handler.next(err);
  }
}
