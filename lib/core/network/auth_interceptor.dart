import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage, Dio? refreshDio, Dio? retryDio})
    : _refreshDio =
          refreshDio ?? Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)),
      _retryDio =
          retryDio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  final TokenStorage _tokenStorage;
  final Dio _refreshDio;
  final Dio _retryDio;

  Future<String?>? _refreshFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublicEndpoint =
        options.path.endsWith('/auth/login') ||
        options.path.endsWith('/auth/refresh');

    if (isPublicEndpoint) {
      handler.next(options);
      return;
    }

    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          message: 'Unable to read the authentication session.',
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isRefreshRequest = request.path.endsWith('/auth/refresh');
    final alreadyRetried = request.extra['authRetry'] == true;

    if (err.response?.statusCode != 401 || isRefreshRequest || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      _refreshFuture ??= _refreshAccessToken();

      final newAccessToken = await _refreshFuture;
      _refreshFuture = null;

      if (newAccessToken == null) {
        handler.next(err);
        return;
      }

      request.headers['Authorization'] = 'Bearer $newAccessToken';
      request.extra['authRetry'] = true;

      final response = await _retryDio.fetch<dynamic>(request);
      handler.resolve(response);
    } catch (_) {
      _refreshFuture = null;
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _tokenStorage.clearTokens();
        return null;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );

      final data = response.data;
      final accessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (accessToken == null ||
          accessToken.isEmpty ||
          newRefreshToken == null ||
          newRefreshToken.isEmpty) {
        await _tokenStorage.clearTokens();
        return null;
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      return accessToken;
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }
}
