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
        final live = session != null &&
            session.isActive &&
            state.remaining > Duration.zero &&
            payload != null;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Attendance QR', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Employees scan this code. When auto-refresh is on, a new QR is created as soon as the current one expires.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-refresh QR'),
              subtitle: Text(
                state.autoRefresh
                    ? 'New ${state.qrExpirySeconds ~/ 60}-minute code when this one expires'
                    : 'Code stays until it expires or you deactivate it',
              ),
              value: state.autoRefresh,
              onChanged: generating
                  ? null
                  : (enabled) => context
                      .read<AdminBloc>()
                      .add(AdminQrAutoRefreshToggled(enabled)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: generating
                      ? null
                      : () => context
                          .read<AdminBloc>()
                          .add(const AdminQrGenerated(expirySeconds: 120)),
                  child: generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Generate 2 min QR'),
                ),
                OutlinedButton(
                  onPressed: generating
                      ? null
                      : () => context
                          .read<AdminBloc>()
                          .add(const AdminQrGenerated(expirySeconds: 300)),
                  child: const Text('Generate 5 min QR'),
                ),
                if (session != null && session.isActive)
                  TextButton(
                    onPressed: generating
                        ? null
                        : () => context
                            .read<AdminBloc>()
                            .add(const AdminQrDeactivated()),
                    child: const Text('Deactivate'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (payload == null && !generating)
              const EmptyState(
                icon: Icons.qr_code_2,
                title: 'No live QR payload',
                message:
                    'Generate a session to display a scannable code. Leave auto-refresh on to keep a live QR on this screen.',
              )
            else
              AppCard(
                child: Column(
                  children: [
                    if (generating && payload == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: CircularProgressIndicator(),
                      )
                    else if (payload != null)
                      Opacity(
                        opacity: generating ? 0.45 : 1,
                        child: QrImageView(data: payload, size: 240),
                      ),
                    const SizedBox(height: 12),
                    if (generating)
                      const Text('Refreshing QR…')
                    else
                      Text(
                        live
                            ? 'Expires in ${_clock(state.remaining)}'
                            : state.autoRefresh
                                ? 'Expired — generating a new code'
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
