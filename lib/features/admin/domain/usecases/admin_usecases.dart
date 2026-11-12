import 'package:smart_qr_attendance/features/admin/domain/entities/admin_entities.dart';
import 'package:smart_qr_attendance/features/admin/domain/repositories/admin_repository.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

class LoadAdminDashboardUseCase {
  LoadAdminDashboardUseCase(this._repository);
  final AdminRepository _repository;

  Future<AdminSnapshot> call({String? date}) async {
    final stats = await _repository.dashboard(date: date);
    final employees = await _repository.employees();
    final attendance = await _repository.attendance(date: date);
    final session = await _repository.activeSession();
    return AdminSnapshot(
      stats: stats,
      employees: employees,
      attendance: attendance,
      activeSession: session,
    );
  }
}

class GenerateQrUseCase {
  GenerateQrUseCase(this._repository);
  final AdminRepository _repository;

  Future<QrSession> call({int? expirySeconds}) {
    return _repository.generateQr(expirySeconds: expirySeconds);
  }
}

class DeactivateQrUseCase {
  DeactivateQrUseCase(this._repository);
  final AdminRepository _repository;

  Future<QrSession> call(String sessionId) {
    return _repository.deactivate(sessionId);
  }
}
