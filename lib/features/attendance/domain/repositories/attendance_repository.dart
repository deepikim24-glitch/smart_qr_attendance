import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceMarkResult> mark({
    required String sessionId,
    required String qrToken,
    required double latitude,
    required double longitude,
  });

  Future<List<AttendanceEntity>> history({String? date});
}
