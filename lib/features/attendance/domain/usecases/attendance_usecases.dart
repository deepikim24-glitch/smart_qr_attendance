import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/repositories/attendance_repository.dart';

class MarkAttendanceUseCase {
  MarkAttendanceUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<AttendanceMarkResult> call({
    required String sessionId,
    required String qrToken,
    required double latitude,
    required double longitude,
  }) {
    return _repository.mark(
      sessionId: sessionId,
      qrToken: qrToken,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class GetAttendanceHistoryUseCase {
  GetAttendanceHistoryUseCase(this._repository);
  final AttendanceRepository _repository;

  Future<List<AttendanceEntity>> call({String? date}) {
    return _repository.history(date: date);
  }
}
