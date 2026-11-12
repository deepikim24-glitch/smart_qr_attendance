import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Not signed in',
              message: 'Please sign in to view your profile.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.isEmpty ? '?' : user.name.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: StatusChip(
                    label: user.role.toUpperCase(),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                child: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }
}
