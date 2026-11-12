import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_qr_attendance/core/errors/exceptions.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/core/utils/location_service.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:smart_qr_attendance/features/qr_scanner/domain/entities/qr_payload.dart';

part 'qr_scanner_event.dart';
part 'qr_scanner_state.dart';

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  QRScannerBloc({
    required MarkAttendanceUseCase markAttendance,
    required LocationService locationService,
  }) : _markAttendance = markAttendance,
       _locationService = locationService,
       super(const QRScannerState()) {
    on<QRScannerStarted>(_onStarted);
    on<QRCodeDetected>(_onDetected);
    on<QRScannerReset>(_onReset);
  }

  final MarkAttendanceUseCase _markAttendance;
  final LocationService _locationService;

  Future<void> _onStarted(
    QRScannerStarted event,
    Emitter<QRScannerState> emit,
  ) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      emit(state.copyWith(
        status: QRScannerStatus.permissionDenied,
        message: 'Camera permission is required to scan the attendance QR code.',
      ));
      return;
    }
    emit(const QRScannerState(status: QRScannerStatus.ready));
  }

  Future<void> _onDetected(
    QRCodeDetected event,
    Emitter<QRScannerState> emit,
  ) async {
    if (state.status != QRScannerStatus.ready &&
        state.status != QRScannerStatus.initial) {
      return;
    }

    late final QrPayload payload;
    try {
      payload = QrPayload.parse(event.rawValue);
    } catch (_) {
      emit(state.copyWith(
        status: QRScannerStatus.failure,
        message: 'This QR code is not a valid attendance session.',
      ));
      return;
    }

    emit(state.copyWith(status: QRScannerStatus.submitting, clearMessage: true));

    try {
      final point = await _locationService.currentPosition();
      final result = await _markAttendance(
        sessionId: payload.sessionId,
        qrToken: payload.token,
        latitude: point.latitude,
        longitude: point.longitude,
      );
      emit(state.copyWith(status: QRScannerStatus.success, result: result));
    } on ApiException catch (error) {
      emit(state.copyWith(status: QRScannerStatus.failure, message: error.message));
    } on Failure catch (failure) {
      emit(state.copyWith(status: QRScannerStatus.failure, message: failure.message));
    }
  }

  void _onReset(QRScannerReset event, Emitter<QRScannerState> emit) {
    emit(const QRScannerState(status: QRScannerStatus.ready));
  }
}
