import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

class AuthSession {
  const AuthSession({required this.user, required this.token});
  final UserEntity user;
  final String token;
}

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<UserEntity> profile();
  Future<void> logout();
  Future<String?> storedToken();
}
