import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';
import 'package:smart_qr_attendance/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:smart_qr_attendance/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  late MockAttendanceRepository repository;
  late AttendanceBloc bloc;

  final record = AttendanceEntity(
    id: 'a1',
    employeeId: 'e1',
    sessionId: 's1',
    attendanceDate: DateTime.utc(2026, 11, 12),
    status: 'checked_in',
  );

  setUp(() {
    repository = MockAttendanceRepository();
    bloc = AttendanceBloc(GetAttendanceHistoryUseCase(repository));
  });

  tearDown(() => bloc.close());

  blocTest<AttendanceBloc, AttendanceState>(
    'loads history into success state',
    build: () {
      when(() => repository.history(date: any(named: 'date')))
          .thenAnswer((_) async => [record]);
      return bloc;
    },
    act: (bloc) => bloc.add(const AttendanceHistoryRequested()),
    expect: () => [
      const AttendanceState(status: AttendanceStatus.loading),
      AttendanceState(status: AttendanceStatus.success, items: [record]),
    ],
  );

  blocTest<AttendanceBloc, AttendanceState>(
    'maps API failures to error state',
    build: () {
      when(() => repository.history(date: any(named: 'date')))
          .thenThrow(const Failure('No internet connection.', code: 'OFFLINE'));
      return bloc;
    },
    act: (bloc) => bloc.add(const AttendanceHistoryRequested()),
    expect: () => [
      const AttendanceState(status: AttendanceStatus.loading),
      const AttendanceState(
        status: AttendanceStatus.failure,
        message: 'No internet connection.',
      ),
    ],
  );
}
