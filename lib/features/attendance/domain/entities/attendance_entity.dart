import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  const AttendanceEntity({
    required this.id,
    required this.employeeId,
    this.employeeName,
    this.employeeEmail,
    required this.sessionId,
    required this.attendanceDate,
    this.checkIn,
    this.checkOut,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    required this.status,
  });

  final String id;
  final String employeeId;
  final String? employeeName;
  final String? employeeEmail;
  final String sessionId;
  final DateTime attendanceDate;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final String status;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        employeeEmail,
        sessionId,
        attendanceDate,
        checkIn,
        checkOut,
        checkInLatitude,
        checkInLongitude,
        checkOutLatitude,
        checkOutLongitude,
        status,
      ];
}

class AttendanceMarkResult extends Equatable {
  const AttendanceMarkResult({required this.action, required this.attendance});
  final String action;
  final AttendanceEntity attendance;

  @override
  List<Object?> get props => [action, attendance];
}
