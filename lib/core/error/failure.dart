import 'package:equatable/equatable.dart';

abstract class AppFailure extends Equatable {
  const AppFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure(super.message);
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class ParsingFailure extends AppFailure {
  const ParsingFailure(super.message);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
