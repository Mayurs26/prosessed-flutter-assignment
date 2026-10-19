import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';

void main() {
  late Dio dio;
  late AuthRemoteDataSource dataSource;
  late dynamic responseBody;
  late RequestOptions? capturedRequest;

  final loginJson = <String, dynamic>{
    'id': 1,
    'username': 'testuser',
    'email': 'test@example.com',
    'firstName': 'Test',
    'lastName': 'User',
    'gender': 'female',
    'image': 'https://example.com/avatar.png',
    'accessToken': 'access-token',
    'refreshToken': 'refresh-token',
    'phone': '1234567890',
  };

  final userJson = <String, dynamic>{
    'id': 1,
    'username': 'testuser',
    'email': 'test@example.com',
    'firstName': 'Test',
    'lastName': 'User',
    'image': 'https://example.com/avatar.png',
    'phone': '1234567890',
  };

  setUp(() {
    responseBody = loginJson;
    capturedRequest = null;

    dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequest = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: responseBody,
              statusCode: 200,
            ),
          );
        },
      ),
    );

    dataSource = AuthRemoteDataSource(dio);
  });

  test('login sends credentials and parses the response', () async {
    final result = await dataSource.login(
      username: 'testuser',
      password: 'password123',
    );

    expect(capturedRequest?.path, '/auth/login');
    expect(capturedRequest?.data, {
      'username': 'testuser',
      'password': 'password123',
      'expiresInMins': 30,
    });

    expect(result.id, 1);
    expect(result.username, 'testuser');
    expect(result.accessToken, 'access-token');
    expect(result.refreshToken, 'refresh-token');
    expect(result.phone, '1234567890');
  });

  test('login throws FormatException for an empty response', () async {
    responseBody = null;

    await expectLater(
      dataSource.login(username: 'testuser', password: 'password123'),
      throwsA(isA<FormatException>()),
    );
  });

  test('getCurrentUser requests and parses the current user', () async {
    responseBody = userJson;

    final result = await dataSource.getCurrentUser();

    expect(capturedRequest?.path, '/auth/me');
    expect(result.id, 1);
    expect(result.username, 'testuser');
    expect(result.email, 'test@example.com');
    expect(result.phone, '1234567890');
  });

  test('getCurrentUser throws FormatException for an empty response', () async {
    responseBody = null;

    await expectLater(
      dataSource.getCurrentUser(),
      throwsA(isA<FormatException>()),
    );
  });

  test('login accepts a missing optional phone number', () async {
    responseBody = Map<String, dynamic>.from(loginJson)..remove('phone');

    final result = await dataSource.login(
      username: 'testuser',
      password: 'password123',
    );

    expect(result.phone, isNull);
  });
}
