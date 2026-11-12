import 'package:smart_qr_attendance/core/network/api_client.dart';
import 'package:smart_qr_attendance/features/attendance/data/models/attendance_model.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource(this._client);
  final ApiClient _client;

  Future<AttendanceMarkResult> mark({
    required String sessionId,
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.post(
      '/api/attendance/mark',
      data: {
        'sessionId': sessionId,
        'qrToken': qrToken,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    return AttendanceMarkResult(
      action: data['action'].toString(),
      attendance: AttendanceModel.fromJson(data['attendance'] as Map<String, dynamic>),
    );
  }

  Future<List<AttendanceModel>> history({String? date}) async {
    final response = await _client.get(
      '/api/attendance/history',
      query: {
        if (date != null) 'date': date,
        'pageSize': 50,
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return items.map(AttendanceModel.fromJson).toList();
  }
}
