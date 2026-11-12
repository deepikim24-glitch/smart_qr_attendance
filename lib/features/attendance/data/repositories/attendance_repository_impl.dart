import 'package:smart_qr_attendance/core/errors/exceptions.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);
  final AttendanceRemoteDataSource _remote;

  @override
  Future<AttendanceMarkResult> mark({
    required String sessionId,
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _remote.mark(
        sessionId: sessionId,
        qrToken: qrToken,
        latitude: latitude,
        longitude: longitude,
      );
    } on ApiException catch (error) {
      throw Failure(error.message, code: error.code, statusCode: error.statusCode);
    }
  }

  @override
  Future<List<AttendanceEntity>> history({String? date}) async {
    try {
      return await _remote.history(date: date);
    } on ApiException catch (error) {
      throw Failure(error.message, code: error.code, statusCode: error.statusCode);
    }
  }
}
