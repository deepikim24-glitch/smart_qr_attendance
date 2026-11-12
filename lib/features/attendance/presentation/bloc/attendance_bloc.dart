import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/usecases/attendance_usecases.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc(this._history) : super(const AttendanceState()) {
    on<AttendanceHistoryRequested>(_onLoad);
    on<AttendanceDateFiltered>(_onFilter);
  }

  final GetAttendanceHistoryUseCase _history;

  Future<void> _onLoad(
    AttendanceHistoryRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading, clearMessage: true));
    await _fetch(emit, state.filterDate);
  }

  Future<void> _onFilter(
    AttendanceDateFiltered event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
      status: AttendanceStatus.loading,
      filterDate: event.date,
      clearDate: event.date == null,
    ));
    await _fetch(emit, event.date);
  }

  Future<void> _fetch(Emitter<AttendanceState> emit, String? date) async {
    try {
      final items = await _history(date: date);
      emit(state.copyWith(status: AttendanceStatus.success, items: items));
    } on Failure catch (failure) {
      emit(state.copyWith(status: AttendanceStatus.failure, message: failure.message));
    }
  }
}
