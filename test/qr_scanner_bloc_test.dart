import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/core/utils/location_service.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:smart_qr_attendance/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:smart_qr_attendance/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockAttendanceRepository repository;
  late MockLocationService location;
  late QRScannerBloc bloc;

  final result = AttendanceMarkResult(
    action: 'check_in',
    attendance: AttendanceEntity(
      id: 'a1',
      employeeId: 'e1',
      sessionId: 's1',
      attendanceDate: DateTime.utc(2026, 11, 12),
      status: 'checked_in',
    ),
  );

  setUp(() {
    repository = MockAttendanceRepository();
    location = MockLocationService();
    bloc = QRScannerBloc(
      markAttendance: MarkAttendanceUseCase(repository),
      locationService: location,
    );
  });

  tearDown(() => bloc.close());

  blocTest<QRScannerBloc, QRScannerState>(
    'rejects invalid QR payloads without calling the API',
    build: () => bloc,
    act: (bloc) => bloc.add(const QRCodeDetected('not-json')),
    expect: () => [
      const QRScannerState(
        status: QRScannerStatus.failure,
        message: 'This QR code is not a valid attendance session.',
      ),
    ],
    verify: (_) {
      verifyNever(() => repository.mark(
            sessionId: any(named: 'sessionId'),
            qrToken: any(named: 'qrToken'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ));
    },
  );

  blocTest<QRScannerBloc, QRScannerState>(
    'submits once and emits success after backend confirmation',
    build: () {
      when(() => location.currentPosition())
          .thenAnswer((_) async => const GeoPoint(11.6643, 78.146));
      when(() => repository.mark(
            sessionId: any(named: 'sessionId'),
            qrToken: any(named: 'qrToken'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenAnswer((_) async => result);
      return bloc;
    },
    act: (bloc) => bloc.add(
      const QRCodeDetected('{"sessionId":"11111111-1111-1111-1111-111111111111","token":"abc"}'),
    ),
    expect: () => [
      const QRScannerState(status: QRScannerStatus.submitting),
      QRScannerState(status: QRScannerStatus.success, result: result),
    ],
  );

  blocTest<QRScannerBloc, QRScannerState>(
    'does not claim success when the API fails',
    build: () {
      when(() => location.currentPosition())
          .thenAnswer((_) async => const GeoPoint(11.6643, 78.146));
      when(() => repository.mark(
            sessionId: any(named: 'sessionId'),
            qrToken: any(named: 'qrToken'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenThrow(const Failure('This attendance QR code has expired', statusCode: 410));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const QRCodeDetected('{"sessionId":"11111111-1111-1111-1111-111111111111","token":"abc"}'),
    ),
    expect: () => [
      const QRScannerState(status: QRScannerStatus.submitting),
      const QRScannerState(
        status: QRScannerStatus.failure,
        message: 'This attendance QR code has expired',
      ),
    ],
  );

  test('ignores a second scan while a request is already submitting', () async {
    when(() => location.currentPosition()).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      return const GeoPoint(11.6643, 78.146);
    });
    when(() => repository.mark(
          sessionId: any(named: 'sessionId'),
          qrToken: any(named: 'qrToken'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async => result);

    bloc.add(
      const QRCodeDetected('{"sessionId":"11111111-1111-1111-1111-111111111111","token":"abc"}'),
    );
    bloc.add(
      const QRCodeDetected('{"sessionId":"11111111-1111-1111-1111-111111111111","token":"abc"}'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));
    verify(() => repository.mark(
          sessionId: any(named: 'sessionId'),
          qrToken: any(named: 'qrToken'),
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).called(1);
  });
}
