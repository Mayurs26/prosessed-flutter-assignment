import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  const loginResponse = LoginResponseModel(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    gender: 'female',
    image: 'https://example.com/avatar.png',
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    phone: '1234567890',
  );

  const currentUser = CurrentUserModel(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/avatar.png',
    phone: '1234567890',
  );

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    tokenStorage = MockTokenStorage();

    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      tokenStorage: tokenStorage,
    );
  });

  test('login saves tokens and returns an auth session', () async {
    when(
      () =>
          remoteDataSource.login(username: 'testuser', password: 'password123'),
    ).thenAnswer((_) async => loginResponse);

    when(
      () => tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    ).thenAnswer((_) async {});

    final session = await repository.login(
      username: 'testuser',
      password: 'password123',
    );

    expect(session.id, 1);
    expect(session.username, 'testuser');
    expect(session.fullName, 'Test User');
    expect(session.accessToken, 'access-token');
    expect(session.refreshToken, 'refresh-token');
    expect(session.phone, '1234567890');

    verify(
      () => tokenStorage.saveTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      ),
    ).called(1);
  });

  test('getCurrentUser restores session using saved tokens', () async {
    when(() => tokenStorage.getAccessToken())
        .thenAnswer((_) async => 'saved-access');
    when(() => tokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'saved-refresh');
    when(() => remoteDataSource.getCurrentUser())
        .thenAnswer((_) async => currentUser);

    final session = await repository.getCurrentUser();

    expect(session.id, 1);
    expect(session.username, 'testuser');
    expect(session.accessToken, 'saved-access');
    expect(session.refreshToken, 'saved-refresh');
    expect(session.fullName, 'Test User');

    verify(() => remoteDataSource.getCurrentUser()).called(1);
  });

  test('getCurrentUser rejects a missing access token', () async {
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => null);
    when(() => tokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'saved-refresh');

    await expectLater(repository.getCurrentUser(), throwsA(isA<StateError>()));

    verifyNever(() => remoteDataSource.getCurrentUser());
  });

  test('getCurrentUser rejects an empty access token', () async {
    when(() => tokenStorage.getAccessToken()).thenAnswer((_) async => '');
    when(() => tokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'saved-refresh');

    await expectLater(repository.getCurrentUser(), throwsA(isA<StateError>()));

    verifyNever(() => remoteDataSource.getCurrentUser());
  });

  test(
    'getCurrentUser uses an empty refresh token when none is saved',
    () async {
      when(() => tokenStorage.getAccessToken())
          .thenAnswer((_) async => 'saved-access');
      when(() => tokenStorage.getRefreshToken()).thenAnswer((_) async => null);
      when(() => remoteDataSource.getCurrentUser())
          .thenAnswer((_) async => currentUser);

      final session = await repository.getCurrentUser();

      expect(session.accessToken, 'saved-access');
      expect(session.refreshToken, '');

      verify(() => remoteDataSource.getCurrentUser()).called(1);
    },
  );

  test('logout clears saved tokens', () async {
    when(() => tokenStorage.clearTokens()).thenAnswer((_) async {});

    await repository.logout();

    verify(() => tokenStorage.clearTokens()).called(1);
  });
}
