import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.stats == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = state.stats;
        return RefreshIndicator(
          onRefresh: () async {
            context.read<AdminBloc>().add(const AdminDashboardRequested());
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Today at a glance', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (stats == null)
                const EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'No data yet',
                  message: 'Dashboard statistics will appear after employees are seeded.',
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 700;
                    final cards = [
                      StatCard(
                        label: 'Employees',
                        value: '${stats.totalEmployees}',
                        icon: Icons.groups_outlined,
                      ),
                      StatCard(
                        label: 'Present',
                        value: '${stats.presentEmployees}',
                        icon: Icons.check_circle_outline,
                      ),
                      StatCard(
                        label: 'Absent',
                        value: '${stats.absentEmployees}',
                        icon: Icons.event_busy_outlined,
                      ),
                      StatCard(
                        label: 'Checked in now',
                        value: '${stats.currentlyCheckedIn}',
                        icon: Icons.login,
                      ),
                    ];
                    if (wide) {
                      return Row(
                        children: [
                          for (final card in cards)
                            Expanded(child: Padding(padding: const EdgeInsets.all(6), child: card)),
                        ],
                      );
                    }
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      children: cards,
                    );
                  },
                ),
              const SizedBox(height: 16),
              const AppCard(
                child: Text(
                  'GPS from a phone cannot independently prove physical presence. '
                  'If geofencing is enabled on the server, it only compares reported coordinates to a configured radius.',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
