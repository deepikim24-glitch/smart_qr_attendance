import 'package:dio/dio.dart';
import 'package:smart_qr_attendance/core/constants/api_constants.dart';
import 'package:smart_qr_attendance/core/errors/exceptions.dart';
import 'package:smart_qr_attendance/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    Dio? dio,
    void Function()? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized,
       _dio = dio ??
           Dio(
             BaseOptions(
               baseUrl: ApiConstants.baseUrl,
               connectTimeout: ApiConstants.connectTimeout,
               receiveTimeout: ApiConstants.receiveTimeout,
               headers: {'Content-Type': 'application/json'},
             ),
           ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final status = error.response?.statusCode;
          if (status == 401) {
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final void Function()? _onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) {
    return _request(() => _dio.get(path, queryParameters: query));
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) {
    return _request(() => _dio.post(path, data: data));
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'success': true, 'data': data};
    } on DioException catch (error) {
      throw _mapDio(error);
    }
  }

  ApiException _mapDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'The request timed out. Check your connection and try again.',
          code: 'TIMEOUT',
          statusCode: 408,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Please reconnect and retry.',
          code: 'OFFLINE',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final body = error.response?.data;
        String message = _defaultMessage(status);
        String? code;
        if (body is Map && body['error'] is Map) {
          message = body['error']['message']?.toString() ?? message;
          code = body['error']['code']?.toString();
        }
        return ApiException(message, code: code, statusCode: status);
      default:
        return const ApiException(
          'Unable to reach the server. Please try again.',
          code: 'NETWORK',
        );
    }
  }

  String _defaultMessage(int? status) {
    switch (status) {
      case 400:
        return 'The request was invalid.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'Attendance for today is already complete.';
      case 410:
        return 'This QR code has expired or been deactivated.';
      case 500:
        return 'The server encountered an error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
