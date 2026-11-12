part of 'attendance_bloc.dart';

enum AttendanceStatus { initial, loading, success, failure }

class AttendanceState extends Equatable {
  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.items = const [],
    this.filterDate,
    this.message,
  });

  final AttendanceStatus status;
  final List<AttendanceEntity> items;
  final String? filterDate;
  final String? message;

  AttendanceState copyWith({
    AttendanceStatus? status,
    List<AttendanceEntity>? items,
    String? filterDate,
    String? message,
    bool clearDate = false,
    bool clearMessage = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      items: items ?? this.items,
      filterDate: clearDate ? null : filterDate ?? this.filterDate,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, filterDate, message];
}
