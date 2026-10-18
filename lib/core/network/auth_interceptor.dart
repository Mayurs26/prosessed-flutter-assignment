import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage});

  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Login and token refresh requests must not use the old access token.
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
}
