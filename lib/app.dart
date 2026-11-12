import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/di/injection.dart';
import 'package:smart_qr_attendance/core/theme/app_theme.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:smart_qr_attendance/features/admin/presentation/pages/admin_shell_page.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/pages/employee_dashboard_page.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_qr_attendance/features/auth/presentation/pages/login_page.dart';

class SmartQrApp extends StatelessWidget {
  const SmartQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl.authBloc()..add(const AuthStarted())),
      ],
      child: MaterialApp(
        title: 'Smart QR Attendance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.unknown) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state.status == AuthStatus.authenticated && state.user != null) {
          if (state.user!.isAdmin) {
            return BlocProvider(
              create: (_) => sl.adminBloc()..add(const AdminDashboardRequested()),
              child: const AdminShellPage(),
            );
          }
          return BlocProvider(
            create: (_) => sl.attendanceBloc()..add(const AttendanceHistoryRequested()),
            child: const EmployeeDashboardPage(),
          );
        }
        return const LoginPage();
      },
    );
  }
}
