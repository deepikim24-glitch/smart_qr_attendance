import 'package:equatable/equatable.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalEmployees,
    required this.presentEmployees,
    required this.absentEmployees,
    required this.currentlyCheckedIn,
  });

  final int totalEmployees;
  final int presentEmployees;
  final int absentEmployees;
  final int currentlyCheckedIn;

  @override
  List<Object?> get props => [
        totalEmployees,
        presentEmployees,
        absentEmployees,
        currentlyCheckedIn,
      ];
}

class QrSession extends Equatable {
  const QrSession({
    required this.id,
    required this.expiresAt,
    required this.isActive,
    required this.createdAt,
    this.payloadJson,
  });

  final String id;
  final DateTime expiresAt;
  final bool isActive;
  final DateTime createdAt;
  final String? payloadJson;

  @override
  List<Object?> get props => [id, expiresAt, isActive, createdAt, payloadJson];
}

class AdminSnapshot extends Equatable {
  const AdminSnapshot({
    required this.stats,
    required this.employees,
    required this.attendance,
    this.activeSession,
  });

  final DashboardStats stats;
  final List<UserEntity> employees;
  final List<AttendanceEntity> attendance;
  final QrSession? activeSession;

  @override
  List<Object?> get props => [stats, employees, attendance, activeSession];
}
