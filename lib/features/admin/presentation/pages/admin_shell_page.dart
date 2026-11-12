import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:smart_qr_attendance/features/admin/presentation/pages/admin_attendance_page.dart';
import 'package:smart_qr_attendance/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:smart_qr_attendance/features/admin/presentation/pages/admin_employees_page.dart';
import 'package:smart_qr_attendance/features/admin/presentation/pages/generate_qr_page.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_qr_attendance/features/auth/presentation/pages/profile_page.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminDashboardPage(),
      GenerateQrPage(),
      AdminEmployeesPage(),
      AdminAttendancePage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin console'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocListener<AdminBloc, AdminState>(
        listenWhen: (p, c) => c.status == AdminStatus.failure && c.message != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
        },
        child: pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'QR'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'People'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), label: 'Records'),
        ],
      ),
    );
  }
}
