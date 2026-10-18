import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthLoggingOut extends AuthState {
  const AuthLoggingOut();
}
