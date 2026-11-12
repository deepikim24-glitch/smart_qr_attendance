import 'package:smart_qr_attendance/features/admin/domain/entities/admin_entities.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

abstract class AdminRepository {
  Future<DashboardStats> dashboard({String? date});
  Future<List<UserEntity>> employees();
  Future<List<AttendanceEntity>> attendance({String? date});
  Future<QrSession> generateQr({int? expirySeconds});
  Future<QrSession> deactivate(String sessionId);
  Future<QrSession?> activeSession();
}
