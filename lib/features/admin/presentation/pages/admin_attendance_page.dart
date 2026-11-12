import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';

class AdminAttendancePage extends StatelessWidget {
  const AdminAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.filterDate == null
                          ? 'All dates'
                          : 'Filtered: ${state.filterDate}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                        initialDate: DateTime.now(),
                      );
                      if (selected != null && context.mounted) {
                        context.read<AdminBloc>().add(
                              AdminDateFiltered(DateTimeUtils.ymd(selected)),
                            );
                      }
                    },
                    child: const Text('Filter'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<AdminBloc>().add(const AdminDateFiltered(null)),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.attendance.isEmpty
                  ? const EmptyState(
                      icon: Icons.fact_check_outlined,
                      title: 'No attendance records',
                      message: 'Records appear after employees scan a valid QR code.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.attendance.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = state.attendance[index];
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.employeeName ?? item.employeeId,
                                  style: Theme.of(context).textTheme.titleMedium),
                              Text(item.employeeEmail ?? ''),
                              const SizedBox(height: 8),
                              Text(DateTimeUtils.formatDate(item.attendanceDate)),
                              Text('In: ${DateTimeUtils.formatTime(item.checkIn)}'),
                              Text('Out: ${DateTimeUtils.formatTime(item.checkOut)}'),
                              StatusChip.forStatus(item.status),
                              if (item.checkInLatitude != null)
                                Text(
                                  'GPS in: ${item.checkInLatitude!.toStringAsFixed(4)}, ${item.checkInLongitude!.toStringAsFixed(4)}',
                                ),
                              if (item.checkOutLatitude != null)
                                Text(
                                  'GPS out: ${item.checkOutLatitude!.toStringAsFixed(4)}, ${item.checkOutLongitude!.toStringAsFixed(4)}',
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
