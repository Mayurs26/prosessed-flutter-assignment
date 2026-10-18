import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._getCurrentUserUseCase,
    required this._logoutUseCase,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SessionRestoreRequested>(_onSessionRestoreRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  // Log state transitions using the correctly typed Bloc callback.
  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);

    debugPrint(
      'AuthBloc: ${change.currentState.runtimeType} '
      '-> ${change.nextState.runtimeType}',
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final session = await _loginUseCase(
        username: event.username.trim(),
        password: event.password,
      );

      emit(AuthSuccess(session));
    } catch (error, stackTrace) {
      debugPrint('AuthBloc login failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      emit(
        const AuthFailure(
          'Login failed. Please check your credentials and try again.',
        ),
      );
    }
  }

  Future<void> _onSessionRestoreRequested(
    SessionRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final session = await _getCurrentUserUseCase();
      emit(AuthSuccess(session));
    } catch (error, stackTrace) {
      debugPrint('AuthBloc session restore failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Clear stale credentials when session restoration fails.
      try {
        await _logoutUseCase();
      } catch (logoutError) {
        debugPrint('AuthBloc credential cleanup failed: $logoutError');
      }

      emit(const AuthFailure('Your session has expired. Please log in again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoggingOut());

    try {
      await _logoutUseCase();
    } catch (error, stackTrace) {
      debugPrint('AuthBloc logout failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      emit(const AuthInitial());
    }
  }
}
