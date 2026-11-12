part of 'admin_bloc.dart';

enum AdminStatus { initial, loading, generating, success, failure }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.stats,
    this.employees = const [],
    this.attendance = const [],
    this.session,
    this.remaining = Duration.zero,
    this.filterDate,
    this.message,
    this.autoRefresh = true,
    this.qrExpirySeconds = 120,
  });

  final AdminStatus status;
  final DashboardStats? stats;
  final List<UserEntity> employees;
  final List<AttendanceEntity> attendance;
  final QrSession? session;
  final Duration remaining;
  final String? filterDate;
  final String? message;
  final bool autoRefresh;
  final int qrExpirySeconds;

  AdminState copyWith({
    AdminStatus? status,
    DashboardStats? stats,
    List<UserEntity>? employees,
    List<AttendanceEntity>? attendance,
    QrSession? session,
    Duration? remaining,
    String? filterDate,
    String? message,
    bool? autoRefresh,
    int? qrExpirySeconds,
    bool clearDate = false,
    bool clearMessage = false,
    bool clearPayload = false,
  }) {
    final nextSession = session ?? this.session;
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      employees: employees ?? this.employees,
      attendance: attendance ?? this.attendance,
      session: clearPayload
          ? (nextSession == null
              ? null
              : QrSession(
                  id: nextSession.id,
                  expiresAt: nextSession.expiresAt,
                  isActive: false,
                  createdAt: nextSession.createdAt,
                ))
          : nextSession,
      remaining: remaining ?? this.remaining,
      filterDate: clearDate ? null : filterDate ?? this.filterDate,
      message: clearMessage ? null : message ?? this.message,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      qrExpirySeconds: qrExpirySeconds ?? this.qrExpirySeconds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stats,
        employees,
        attendance,
        session,
        remaining,
        filterDate,
        message,
        autoRefresh,
        qrExpirySeconds,
      ];
}
