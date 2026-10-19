import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/storage/token_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  const accessTokenKey = 'access_token';
  const refreshTokenKey = 'refresh_token';

  setUp(() {
    secureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
  });

  group('TokenStorage', () {
    test('saveTokens writes both access and refresh tokens', () async {
      when(() => secureStorage.write(key: accessTokenKey, value: 'access-123'))
          .thenAnswer((_) async {});

      when(
        () => secureStorage.write(key: refreshTokenKey, value: 'refresh-456'),
      ).thenAnswer((_) async {});

      await tokenStorage.saveTokens(
        accessToken: 'access-123',
        refreshToken: 'refresh-456',
      );

      verify(
        () => secureStorage.write(key: accessTokenKey, value: 'access-123'),
      ).called(1);

      verify(
        () => secureStorage.write(key: refreshTokenKey, value: 'refresh-456'),
      ).called(1);
    });

    test('getAccessToken reads the saved access token', () async {
      when(() => secureStorage.read(key: accessTokenKey))
          .thenAnswer((_) async => 'access-123');

      final result = await tokenStorage.getAccessToken();

      expect(result, 'access-123');
      verify(() => secureStorage.read(key: accessTokenKey)).called(1);
    });

    test('getRefreshToken reads the saved refresh token', () async {
      when(() => secureStorage.read(key: refreshTokenKey))
          .thenAnswer((_) async => 'refresh-456');

      final result = await tokenStorage.getRefreshToken();

      expect(result, 'refresh-456');
      verify(() => secureStorage.read(key: refreshTokenKey)).called(1);
    });

    test('hasSession returns true when access token exists', () async {
      when(() => secureStorage.read(key: accessTokenKey))
          .thenAnswer((_) async => 'access-123');

      expect(await tokenStorage.hasSession(), isTrue);
    });

    test('hasSession returns false for null or empty access token', () async {
      when(() => secureStorage.read(key: accessTokenKey))
          .thenAnswer((_) async => null);

      expect(await tokenStorage.hasSession(), isFalse);

      when(() => secureStorage.read(key: accessTokenKey))
          .thenAnswer((_) async => '');

      expect(await tokenStorage.hasSession(), isFalse);
    });

    test('clearTokens deletes both stored tokens', () async {
      when(() => secureStorage.delete(key: accessTokenKey))
          .thenAnswer((_) async {});

      when(() => secureStorage.delete(key: refreshTokenKey))
          .thenAnswer((_) async {});

      await tokenStorage.clearTokens();

      verify(() => secureStorage.delete(key: accessTokenKey)).called(1);

      verify(() => secureStorage.delete(key: refreshTokenKey)).called(1);
    });
  });
}
