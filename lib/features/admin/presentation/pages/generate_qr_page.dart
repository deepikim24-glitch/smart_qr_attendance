import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/admin/presentation/bloc/admin_bloc.dart';

class GenerateQrPage extends StatelessWidget {
  const GenerateQrPage({super.key});

  String _clock(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final session = state.session;
        final payload = session?.payloadJson;
        final generating = state.status == AdminStatus.generating;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Attendance QR', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Employees scan this code. Expiry is enforced by the server, not the phone.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: generating
                      ? null
                      : () => context.read<AdminBloc>().add(const AdminQrGenerated(expirySeconds: 120)),
                  child: generating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Generate 2 min QR'),
                ),
                OutlinedButton(
                  onPressed: generating
                      ? null
                      : () => context.read<AdminBloc>().add(const AdminQrGenerated(expirySeconds: 300)),
                  child: const Text('Generate 5 min QR'),
                ),
                if (session != null && session.isActive)
                  TextButton(
                    onPressed: () => context.read<AdminBloc>().add(const AdminQrDeactivated()),
                    child: const Text('Deactivate'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (payload == null)
              const EmptyState(
                icon: Icons.qr_code_2,
                title: 'No live QR payload',
                message: 'Generate a new session to display a scannable code. Active sessions without a payload still expire on the server.',
              )
            else
              AppCard(
                child: Column(
                  children: [
                    QrImageView(data: payload, size: 240),
                    const SizedBox(height: 12),
                    Text(
                      session!.isActive && state.remaining > Duration.zero
                          ? 'Expires in ${_clock(state.remaining)}'
                          : 'Expired or deactivated',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
