part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class AttendanceHistoryRequested extends AttendanceEvent {
  const AttendanceHistoryRequested();
}

class AttendanceDateFiltered extends AttendanceEvent {
  const AttendanceDateFiltered(this.date);
  final String? date;
  @override
  List<Object?> get props => [date];
}
