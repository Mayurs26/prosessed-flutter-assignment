import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

class SessionRestoreRequested extends AuthEvent {
  const SessionRestoreRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
