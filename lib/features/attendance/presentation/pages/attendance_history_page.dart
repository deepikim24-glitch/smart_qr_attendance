import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/attendance/presentation/bloc/attendance_bloc.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance history'),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDate: DateTime.now(),
              );
              if (selected != null && context.mounted) {
                context.read<AttendanceBloc>().add(
                      AttendanceDateFiltered(DateTimeUtils.ymd(selected)),
                    );
              }
            },
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
            onPressed: () => context
                .read<AttendanceBloc>()
                .add(const AttendanceDateFiltered(null)),
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.status == AttendanceStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AttendanceStatus.failure) {
            return ErrorBanner(
              message: state.message ?? 'Unable to load history.',
              onRetry: () => context
                  .read<AttendanceBloc>()
                  .add(const AttendanceHistoryRequested()),
            );
          }
          if (state.items.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No records',
              message: 'Attendance history will appear here after you scan a QR code.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(DateTimeUtils.formatDate(item.attendanceDate))),
                        StatusChip.forStatus(item.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Check-in: ${DateTimeUtils.formatTime(item.checkIn)}'),
                    Text('Check-out: ${DateTimeUtils.formatTime(item.checkOut)}'),
                    if (item.checkInLatitude != null)
                      Text(
                        'In: ${item.checkInLatitude!.toStringAsFixed(4)}, ${item.checkInLongitude!.toStringAsFixed(4)}',
                      ),
                    if (item.checkOutLatitude != null)
                      Text(
                        'Out: ${item.checkOutLatitude!.toStringAsFixed(4)}, ${item.checkOutLongitude!.toStringAsFixed(4)}',
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
