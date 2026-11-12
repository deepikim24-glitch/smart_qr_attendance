import 'package:flutter/material.dart';
import 'package:smart_qr_attendance/core/utils/date_time_utils.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceSuccessPage extends StatelessWidget {
  const AttendanceSuccessPage({super.key, required this.result});

  final AttendanceMarkResult result;

  @override
  Widget build(BuildContext context) {
    final isCheckIn = result.action == 'check_in';
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance recorded')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isCheckIn ? 'Check-in successful' : 'Check-out successful',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'The server confirmed this record. Do not rescan unless you still need to check out.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip.forStatus(result.attendance.status),
                  const SizedBox(height: 8),
                  Text('Date: ${DateTimeUtils.formatDate(result.attendance.attendanceDate)}'),
                  Text('Check-in: ${DateTimeUtils.formatTime(result.attendance.checkIn)}'),
                  Text('Check-out: ${DateTimeUtils.formatTime(result.attendance.checkOut)}'),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
