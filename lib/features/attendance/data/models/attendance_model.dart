import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.employeeId,
    super.employeeName,
    super.employeeEmail,
    required super.sessionId,
    required super.attendanceDate,
    super.checkIn,
    super.checkOut,
    super.checkInLatitude,
    super.checkInLongitude,
    super.checkOutLatitude,
    super.checkOutLongitude,
    required super.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'].toString(),
      employeeId: json['employeeId'].toString(),
      employeeName: json['employeeName']?.toString(),
      employeeEmail: json['employeeEmail']?.toString(),
      sessionId: json['sessionId'].toString(),
      attendanceDate: DateTimeUtils.tryParse(json['attendanceDate']) ?? DateTime.now(),
      checkIn: DateTimeUtils.tryParse(json['checkIn']),
      checkOut: DateTimeUtils.tryParse(json['checkOut']),
      checkInLatitude: (json['checkInLatitude'] as num?)?.toDouble(),
      checkInLongitude: (json['checkInLongitude'] as num?)?.toDouble(),
      checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
      status: json['status'].toString(),
    );
  }
}
