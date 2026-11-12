import 'package:smart_qr_attendance/core/network/api_client.dart';
import 'package:smart_qr_attendance/core/storage/token_storage.dart';
import 'package:smart_qr_attendance/core/utils/location_service.dart';
import 'package:smart_qr_attendance/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:smart_qr_attendance/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:smart_qr_attendance/features/admin/domain/usecases/admin_usecases.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:smart_qr_attendance/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:smart_qr_attendance/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:smart_qr_attendance/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:smart_qr_attendance/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_qr_attendance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smart_qr_attendance/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_qr_attendance/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';

class ServiceLocator {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final AuthRepositoryImpl authRepository;
  late final AttendanceRepositoryImpl attendanceRepository;
  late final AdminRepositoryImpl adminRepository;
  late final LocationService locationService;
  late final LoginUseCase loginUseCase;
  late final RestoreSessionUseCase restoreSessionUseCase;
  late final LogoutUseCase logoutUseCase;
  late final GetAttendanceHistoryUseCase historyUseCase;
  late final MarkAttendanceUseCase markAttendanceUseCase;
  late final LoadAdminDashboardUseCase loadAdminDashboardUseCase;
  late final GenerateQrUseCase generateQrUseCase;
  late final DeactivateQrUseCase deactivateQrUseCase;

  void init({void Function()? onUnauthorized}) {
    tokenStorage = TokenStorage();
    apiClient = ApiClient(
      tokenStorage: tokenStorage,
      onUnauthorized: onUnauthorized,
    );
    authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(apiClient),
      tokenStorage,
    );
    attendanceRepository = AttendanceRepositoryImpl(
      AttendanceRemoteDataSource(apiClient),
    );
    adminRepository = AdminRepositoryImpl(AdminRemoteDataSource(apiClient));
    locationService = LocationService();
    loginUseCase = LoginUseCase(authRepository);
    restoreSessionUseCase = RestoreSessionUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    historyUseCase = GetAttendanceHistoryUseCase(attendanceRepository);
    markAttendanceUseCase = MarkAttendanceUseCase(attendanceRepository);
    loadAdminDashboardUseCase = LoadAdminDashboardUseCase(adminRepository);
    generateQrUseCase = GenerateQrUseCase(adminRepository);
    deactivateQrUseCase = DeactivateQrUseCase(adminRepository);
  }

  AuthBloc authBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        restoreSessionUseCase: restoreSessionUseCase,
        logoutUseCase: logoutUseCase,
      );

  AttendanceBloc attendanceBloc() => AttendanceBloc(historyUseCase);

  QRScannerBloc qrScannerBloc() => QRScannerBloc(
        markAttendance: markAttendanceUseCase,
        locationService: locationService,
      );

  AdminBloc adminBloc() => AdminBloc(
        loadDashboard: loadAdminDashboardUseCase,
        generateQr: generateQrUseCase,
        deactivateQr: deactivateQrUseCase,
      );
}

final sl = ServiceLocator();
