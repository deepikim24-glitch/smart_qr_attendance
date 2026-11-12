import 'dart:convert';

import 'package:smart_qr_attendance/core/network/api_client.dart';
import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/features/admin/domain/entities/admin_entities.dart';
import 'package:smart_qr_attendance/features/attendance/data/models/attendance_model.dart';
import 'package:smart_qr_attendance/features/auth/data/models/user_model.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource(this._client);
  final ApiClient _client;

  Future<DashboardStats> dashboard({String? date}) async {
    final response = await _client.get(
      '/api/admin/dashboard',
      query: {if (date != null) 'date': date},
    );
    final stats = (response['data'] as Map<String, dynamic>)['stats']
        as Map<String, dynamic>;
    return DashboardStats(
      totalEmployees: (stats['totalEmployees'] as num).toInt(),
      presentEmployees: (stats['presentEmployees'] as num).toInt(),
      absentEmployees: (stats['absentEmployees'] as num).toInt(),
      currentlyCheckedIn: (stats['currentlyCheckedIn'] as num).toInt(),
    );
  }

  Future<List<UserModel>> employees() async {
    final response = await _client.get('/api/admin/employees');
    final items = ((response['data'] as Map<String, dynamic>)['items'] as List)
        .cast<Map<String, dynamic>>();
    return items.map(UserModel.fromJson).toList();
  }

  Future<List<AttendanceModel>> attendance({String? date}) async {
    final response = await _client.get(
      '/api/admin/attendance',
      query: {if (date != null) 'date': date},
    );
    final items = ((response['data'] as Map<String, dynamic>)['items'] as List)
        .cast<Map<String, dynamic>>();
    return items.map(AttendanceModel.fromJson).toList();
  }

  Future<QrSession> generateQr({int? expirySeconds}) async {
    final response = await _client.post(
      '/api/qr/generate',
      data: {if (expirySeconds != null) 'expirySeconds': expirySeconds},
    );
    final data = response['data'] as Map<String, dynamic>;
    final session = data['session'] as Map<String, dynamic>;
    final payload = data['payload'];
    return _sessionFromJson(
      session,
      payloadJson: payload == null ? null : jsonEncode(payload),
    );
  }

  Future<QrSession> deactivate(String sessionId) async {
    final response = await _client.post('/api/qr/$sessionId/deactivate');
    final session =
        (response['data'] as Map<String, dynamic>)['session'] as Map<String, dynamic>;
    return _sessionFromJson(session);
  }

  Future<QrSession?> activeSession() async {
    final response = await _client.get('/api/qr/active');
    final session = (response['data'] as Map<String, dynamic>)['session'];
    if (session == null) return null;
    return _sessionFromJson(session as Map<String, dynamic>);
  }

  QrSession _sessionFromJson(Map<String, dynamic> json, {String? payloadJson}) {
    return QrSession(
      id: json['id'].toString(),
      expiresAt: DateTimeUtils.tryParse(json['expiresAt']) ?? DateTime.now(),
      isActive: json['isActive'] == true,
      createdAt: DateTimeUtils.tryParse(json['createdAt']) ?? DateTime.now(),
      payloadJson: payloadJson,
    );
  }
}
