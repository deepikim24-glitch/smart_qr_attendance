import 'package:smart_qr_attendance/core/network/api_client.dart';
import 'package:smart_qr_attendance/features/auth/data/models/user_model.dart';
import 'package:smart_qr_attendance/features/auth/domain/repositories/auth_repository.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final ApiClient _client;

  Future<AuthSession> login(String email, String password) async {
    final response = await _client.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response['data'] as Map<String, dynamic>;
    return AuthSession(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'].toString(),
    );
  }

  Future<UserModel> profile() async {
    final response = await _client.get('/api/auth/profile');
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
