import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/admin/domain/entities/admin_entities.dart';
import 'package:smart_qr_attendance/features/admin/domain/usecases/admin_usecases.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc({
    required LoadAdminDashboardUseCase loadDashboard,
    required GenerateQrUseCase generateQr,
    required DeactivateQrUseCase deactivateQr,
  }) : _loadDashboard = loadDashboard,
       _generateQr = generateQr,
       _deactivateQr = deactivateQr,
       super(const AdminState()) {
    on<AdminDashboardRequested>(_onLoad);
    on<AdminDateFiltered>(_onFilter);
    on<AdminQrGenerated>(_onGenerate);
    on<AdminQrDeactivated>(_onDeactivate);
    on<AdminTicked>(_onTick);
  }

  final LoadAdminDashboardUseCase _loadDashboard;
  final GenerateQrUseCase _generateQr;
  final DeactivateQrUseCase _deactivateQr;
  Timer? _timer;

  Future<void> _onLoad(
    AdminDashboardRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading, clearMessage: true));
    await _refresh(emit, state.filterDate);
  }

  Future<void> _onFilter(
    AdminDateFiltered event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminStatus.loading,
      filterDate: event.date,
      clearDate: event.date == null,
    ));
    await _refresh(emit, event.date);
  }

  Future<void> _refresh(Emitter<AdminState> emit, String? date) async {
    try {
      final snapshot = await _loadDashboard(date: date);
      emit(state.copyWith(
        status: AdminStatus.success,
        stats: snapshot.stats,
        employees: snapshot.employees,
        attendance: snapshot.attendance,
        session: snapshot.activeSession,
        remaining: _remaining(snapshot.activeSession),
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(status: AdminStatus.failure, message: failure.message));
    }
  }

  Future<void> _onGenerate(
    AdminQrGenerated event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.generating));
    try {
      final session = await _generateQr(expirySeconds: event.expirySeconds);
      emit(state.copyWith(
        status: AdminStatus.success,
        session: session,
        remaining: _remaining(session),
      ));
      _startTicker();
    } on Failure catch (failure) {
      emit(state.copyWith(status: AdminStatus.failure, message: failure.message));
    }
  }

  Future<void> _onDeactivate(
    AdminQrDeactivated event,
    Emitter<AdminState> emit,
  ) async {
    final current = state.session;
    if (current == null) return;
    try {
      final session = await _deactivateQr(current.id);
      _timer?.cancel();
      emit(state.copyWith(
        session: session,
        remaining: Duration.zero,
        clearPayload: true,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(status: AdminStatus.failure, message: failure.message));
    }
  }

  void _onTick(AdminTicked event, Emitter<AdminState> emit) {
    final remaining = _remaining(state.session);
    emit(state.copyWith(remaining: remaining));
    if (remaining == Duration.zero) {
      _timer?.cancel();
    }
  }

  Duration _remaining(QrSession? session) {
    if (session == null || !session.isActive) return Duration.zero;
    final end = session.expiresAt.toUtc();
    final diff = end.difference(DateTime.now().toUtc());
    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const AdminTicked());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
