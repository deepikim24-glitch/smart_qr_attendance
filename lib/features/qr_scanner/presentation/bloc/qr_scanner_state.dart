part of 'qr_scanner_bloc.dart';

enum QRScannerStatus {
  initial,
  ready,
  submitting,
  success,
  failure,
  permissionDenied,
}

class QRScannerState extends Equatable {
  const QRScannerState({
    this.status = QRScannerStatus.initial,
    this.message,
    this.result,
  });

  final QRScannerStatus status;
  final String? message;
  final AttendanceMarkResult? result;

  QRScannerState copyWith({
    QRScannerStatus? status,
    String? message,
    AttendanceMarkResult? result,
    bool clearMessage = false,
  }) {
    return QRScannerState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [status, message, result];
}
