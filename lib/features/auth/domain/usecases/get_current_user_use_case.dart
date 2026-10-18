import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call() {
    return _repository.getCurrentUser();
  }
}
