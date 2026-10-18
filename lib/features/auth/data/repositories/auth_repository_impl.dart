import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._tokenStorage,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return AuthSession(
      id: response.id,
      username: response.username,
      email: response.email,
      firstName: response.firstName,
      lastName: response.lastName,
      image: response.image,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      phone: response.phone,
    );
  }

  @override
  Future<AuthSession> getCurrentUser() async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('No saved access token.');
    }

    final user = await _remoteDataSource.getCurrentUser();

    return AuthSession(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      image: user.image,
      accessToken: accessToken,
      refreshToken: refreshToken ?? '',
      phone: user.phone,
    );
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}
