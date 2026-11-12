part of 'qr_scanner_bloc.dart';

abstract class QRScannerEvent extends Equatable {
  const QRScannerEvent();
  @override
  List<Object?> get props => [];
}

class QRScannerStarted extends QRScannerEvent {
  const QRScannerStarted();
}

class QRCodeDetected extends QRScannerEvent {
  const QRCodeDetected(this.rawValue);
  final String rawValue;
  @override
  List<Object?> get props => [rawValue];
}

class QRScannerReset extends QRScannerEvent {
  const QRScannerReset();
}
