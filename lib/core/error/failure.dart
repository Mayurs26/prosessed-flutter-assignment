sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Unable to connect. Check your internet connection.',
  ]);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class ClientFailure extends AppFailure {
  const ClientFailure(super.message);
}

class ParsingFailure extends AppFailure {
  const ParsingFailure([
    super.message = 'Unable to process the server response.',
  ]);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something unexpected happened.']);
}
