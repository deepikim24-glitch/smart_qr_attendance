import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';

class AdminEmployeesPage extends StatelessWidget {
  const AdminEmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.employees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.employees.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_outlined,
            title: 'No employees',
            message: 'Seed or register employee accounts to see them here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.employees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final employee = state.employees[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(employee.name),
                subtitle: Text(employee.email),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
