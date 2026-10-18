import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_use_case.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_use_case.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockLogoutUseCase logoutUseCase;

  const session = AuthSession(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/avatar.png',
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  setUp(() {
    loginUseCase = MockLoginUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    logoutUseCase = MockLogoutUseCase();

    when(() => logoutUseCase()).thenAnswer((_) async {});
  });

  AuthBloc createBloc() {
    return AuthBloc(
      loginUseCase: loginUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      logoutUseCase: logoutUseCase,
    );
  }

  test('initial state is AuthInitial', () {
    final bloc = createBloc();

    expect(bloc.state, isA<AuthInitial>());

    bloc.close();
  });

  blocTest<AuthBloc, AuthState>(
    'emits loading and success when login succeeds',
    build: () {
      when(() => loginUseCase(username: 'testuser', password: 'password123'))
          .thenAnswer((_) async => session);

      return createBloc();
    },
    act: (bloc) => bloc.add(
      const LoginRequested(username: ' testuser ', password: 'password123'),
    ),
    expect: () => [const AuthLoading(), const AuthSuccess(session)],
    verify: (_) {
      verify(() => loginUseCase(username: 'testuser', password: 'password123'))
          .called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits failure when credentials are invalid',
    build: () {
      when(() => loginUseCase(username: 'wronguser', password: 'wrongpassword'))
          .thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              response: Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 400,
              ),
            ),
          );

      return createBloc();
    },
    act: (bloc) => bloc.add(
      const LoginRequested(username: 'wronguser', password: 'wrongpassword'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthFailure('Invalid username or password. Please try again.'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits connection failure when login throws another error',
    build: () {
      when(() => loginUseCase(username: 'testuser', password: 'password123'))
          .thenThrow(Exception('Network error'));

      return createBloc();
    },
    act: (bloc) => bloc.add(
      const LoginRequested(username: 'testuser', password: 'password123'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthFailure(
        'Unable to log in. Please check your connection and try again.',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'restores the existing session successfully',
    build: () {
      when(() => getCurrentUserUseCase()).thenAnswer((_) async => session);

      return createBloc();
    },
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [const AuthLoading(), const AuthSuccess(session)],
    verify: (_) {
      verify(() => getCurrentUserUseCase()).called(1);
      verifyNever(() => logoutUseCase());
    },
  );

  blocTest<AuthBloc, AuthState>(
    'clears credentials when session restoration fails',
    build: () {
      when(() => getCurrentUserUseCase())
          .thenThrow(Exception('Session expired'));

      return createBloc();
    },
    act: (bloc) => bloc.add(const SessionRestoreRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthFailure('Your session has expired. Please log in again.'),
    ],
    verify: (_) {
      verify(() => logoutUseCase()).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits logging out and initial when logout succeeds',
    build: createBloc,
    act: (bloc) => bloc.add(const LogoutRequested()),
    expect: () => [const AuthLoggingOut(), const AuthInitial()],
    verify: (_) {
      verify(() => logoutUseCase()).called(1);
    },
  );
}
