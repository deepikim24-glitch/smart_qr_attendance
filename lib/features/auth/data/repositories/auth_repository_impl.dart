import 'package:smart_qr_attendance/core/errors/exceptions.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/core/storage/token_storage.dart';
import 'package:smart_qr_attendance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remote.login(email, password);
      await _storage.saveToken(session.token);
      return session;
    } on ApiException catch (error) {
      throw Failure(error.message, code: error.code, statusCode: error.statusCode);
    }
  }

  @override
  Future<UserEntity> profile() async {
    try {
      return await _remote.profile();
    } on ApiException catch (error) {
      throw Failure(error.message, code: error.code, statusCode: error.statusCode);
    }
  }

  @override
  Future<void> logout() => _storage.clear();

  @override
  Future<String?> storedToken() => _storage.readToken();
}
