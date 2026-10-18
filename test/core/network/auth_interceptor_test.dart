import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class CallbackAdapter implements HttpClientAdapter {
  CallbackAdapter(this.callback);

  final Future<ResponseBody> Function(RequestOptions options) callback;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return callback(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Map<String, dynamic> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    statusMessage: statusCode == 401 ? 'Unauthorized' : 'OK',
  );
}

void main() {
  late MockTokenStorage storage;

  setUp(() {
    storage = MockTokenStorage();
    when(() => storage.getAccessToken())
        .thenAnswer((_) async => 'old-access-token');
  });

  test('attaches access token to a request', () async {
    RequestOptions? capturedRequest;

    final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    dio.httpClientAdapter = CallbackAdapter((options) async {
      capturedRequest = options;
      return jsonResponse({'id': 1});
    });
    dio.interceptors.add(AuthInterceptor(tokenStorage: storage));

    final response = await dio.get<dynamic>('/products/1');

    expect(response.statusCode, 200);
    expect(
      capturedRequest?.headers['Authorization'],
      'Bearer old-access-token',
    );

    dio.close(force: true);
  });

  test('refreshes token and retries a request after 401', () async {
    var originalRequestCount = 0;
    RequestOptions? retriedRequest;
    Map<String, dynamic>? refreshPayload;

    when(() => storage.getRefreshToken())
        .thenAnswer((_) async => 'old-refresh-token');

    when(
      () => storage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    refreshDio.httpClientAdapter = CallbackAdapter((options) async {
      refreshPayload = options.data as Map<String, dynamic>;
      return jsonResponse({
        'accessToken': 'new-access-token',
        'refreshToken': 'new-refresh-token',
      });
    });

    final retryDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    retryDio.httpClientAdapter = CallbackAdapter((options) async {
      retriedRequest = options;
      return jsonResponse({'id': 1, 'title': 'Test product'});
    });

    final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    dio.httpClientAdapter = CallbackAdapter((options) async {
      originalRequestCount++;
      return jsonResponse({'message': 'Access token expired'}, statusCode: 401);
    });

    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        refreshDio: refreshDio,
        retryDio: retryDio,
      ),
    );

    final response = await dio.get<dynamic>('/products/1');

    expect(response.statusCode, 200);
    expect(originalRequestCount, 1);
    expect(refreshPayload?['refreshToken'], 'old-refresh-token');
    expect(refreshPayload?['expiresInMins'], 30);
    expect(retriedRequest?.headers['Authorization'], 'Bearer new-access-token');

    verify(
      () => storage.saveTokens(
        accessToken: 'new-access-token',
        refreshToken: 'new-refresh-token',
      ),
    ).called(1);

    dio.close(force: true);
    refreshDio.close(force: true);
    retryDio.close(force: true);
  });

  test('clears tokens when refresh token is unavailable', () async {
    when(() => storage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.clearTokens()).thenAnswer((_) async {});

    final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    dio.httpClientAdapter = CallbackAdapter(
      (_) async => jsonResponse({'message': 'Unauthorized'}, statusCode: 401),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage: storage));

    await expectLater(
      dio.get<dynamic>('/products/1'),
      throwsA(isA<DioException>()),
    );

    verify(() => storage.clearTokens()).called(1);

    dio.close(force: true);
  });

  test('clears tokens when refresh request fails', () async {
    when(() => storage.getRefreshToken())
        .thenAnswer((_) async => 'expired-refresh-token');
    when(() => storage.clearTokens()).thenAnswer((_) async {});

    final refreshDio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    refreshDio.httpClientAdapter = CallbackAdapter(
      (_) async =>
          jsonResponse({'message': 'Invalid refresh token'}, statusCode: 401),
    );

    final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
    dio.httpClientAdapter = CallbackAdapter(
      (_) async =>
          jsonResponse({'message': 'Access token expired'}, statusCode: 401),
    );

    dio.interceptors.add(
      AuthInterceptor(tokenStorage: storage, refreshDio: refreshDio),
    );

    await expectLater(
      dio.get<dynamic>('/products/1'),
      throwsA(isA<DioException>()),
    );

    verify(() => storage.clearTokens()).called(1);

    dio.close(force: true);
    refreshDio.close(force: true);
  });
}
