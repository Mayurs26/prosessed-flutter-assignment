import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient({required TokenStorage tokenStorage}) {
    _dio = Dio(
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

    _dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));

    assert(() {
      _dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false, error: true),
      );
      return true;
    }());
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
