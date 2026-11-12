import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_qr_attendance/features/auth/presentation/pages/profile_page.dart';
import 'package:smart_qr_attendance/features/qr_scanner/presentation/pages/qr_scanner_page.dart';

class EmployeeDashboardPage extends StatelessWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My attendance'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, auth) {
          return BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              final today = state.items.where((item) {
                final date = item.attendanceDate.toUtc();
                final now = DateTime.now().toUtc();
                return date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
              }).toList();
              final current = today.isEmpty ? null : today.first;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AttendanceBloc>().add(const AttendanceHistoryRequested());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Hello, ${auth.user?.name ?? 'there'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Scan the office QR code to check in or check out.'),
                    const SizedBox(height: 16),
                    if (state.status == AttendanceStatus.failure)
                      ErrorBanner(
                        message: state.message ?? 'Unable to load attendance.',
                        onRetry: () => context
                            .read<AttendanceBloc>()
                            .add(const AttendanceHistoryRequested()),
                      ),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Today'),
                          const SizedBox(height: 8),
                          if (current == null)
                            const Text('No attendance recorded yet.')
                          else ...[
                            StatusChip.forStatus(current.status),
                            const SizedBox(height: 8),
                            Text('Check-in: ${DateTimeUtils.formatTime(current.checkIn)}'),
                            Text('Check-out: ${DateTimeUtils.formatTime(current.checkOut)}'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QrScannerPage()),
                        );
                        if (context.mounted) {
                          context
                              .read<AttendanceBloc>()
                              .add(const AttendanceHistoryRequested());
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final attendanceBloc = context.read<AttendanceBloc>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: attendanceBloc,
                              child: const AttendanceHistoryPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('Attendance history'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
