import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_qr_attendance/core/di/injection.dart';
import 'package:smart_qr_attendance/core/widgets/app_widgets.dart';
import 'package:smart_qr_attendance/features/qr_scanner/presentation/bloc/qr_scanner_bloc.dart';
import 'package:smart_qr_attendance/features/qr_scanner/presentation/pages/attendance_success_page.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.qrScannerBloc()..add(const QRScannerStarted()),
      child: const _QrScannerView(),
    );
  }
}

class _QrScannerView extends StatelessWidget {
  const _QrScannerView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QRScannerBloc, QRScannerState>(
      listener: (context, state) {
        if (state.status == QRScannerStatus.success && state.result != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AttendanceSuccessPage(result: state.result!),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Scan attendance QR')),
          body: switch (state.status) {
            QRScannerStatus.permissionDenied => EmptyState(
                icon: Icons.camera_alt_outlined,
                title: 'Camera permission needed',
                message: state.message ?? 'Enable camera access to scan QR codes.',
                action: FilledButton(
                  onPressed: () =>
                      context.read<QRScannerBloc>().add(const QRScannerStarted()),
                  child: const Text('Request permission'),
                ),
              ),
            QRScannerStatus.failure => EmptyState(
                icon: Icons.error_outline,
                title: 'Scan failed',
                message: state.message ?? 'Unable to mark attendance.',
                action: FilledButton(
                  onPressed: () =>
                      context.read<QRScannerBloc>().add(const QRScannerReset()),
                  child: const Text('Try again'),
                ),
              ),
            QRScannerStatus.submitting => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Validating QR and location…'),
                  ],
                ),
              ),
            _ => Stack(
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      if (capture.barcodes.isEmpty) return;
                      final value = capture.barcodes.first.rawValue;
                      if (value == null) return;
                      context.read<QRScannerBloc>().add(QRCodeDetected(value));
                    },
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Point your camera at the admin QR code. GPS is captured only after a valid scan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
          },
        );
      },
    );
  }
}
