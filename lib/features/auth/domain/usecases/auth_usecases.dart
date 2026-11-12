import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

class GetProfileUseCase {
  GetProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserEntity> call() => _repository.profile();
}

class LogoutUseCase {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

class RestoreSessionUseCase {
  RestoreSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserEntity?> call() async {
    final token = await _repository.storedToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return _repository.profile();
  }
}
