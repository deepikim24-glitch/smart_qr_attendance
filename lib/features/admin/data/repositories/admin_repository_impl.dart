import 'package:smart_qr_attendance/core/errors/exceptions.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:smart_qr_attendance/features/admin/domain/entities/admin_entities.dart';
import 'package:smart_qr_attendance/features/admin/domain/repositories/admin_repository.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);
  final AdminRemoteDataSource _remote;

  @override
  Future<DashboardStats> dashboard({String? date}) {
    return _wrap(() => _remote.dashboard(date: date));
  }

  @override
  Future<List<UserEntity>> employees() => _wrap(_remote.employees);

  @override
  Future<List<AttendanceEntity>> attendance({String? date}) {
    return _wrap(() => _remote.attendance(date: date));
  }

  @override
  Future<QrSession> generateQr({int? expirySeconds}) {
    return _wrap(() => _remote.generateQr(expirySeconds: expirySeconds));
  }

  @override
  Future<QrSession> deactivate(String sessionId) {
    return _wrap(() => _remote.deactivate(sessionId));
  }

  @override
  Future<QrSession?> activeSession() => _wrap(_remote.activeSession);

  Future<T> _wrap<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (error) {
      throw Failure(error.message, code: error.code, statusCode: error.statusCode);
    }
  }
}
