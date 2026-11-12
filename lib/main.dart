import 'package:flutter/material.dart';
import 'package:smart_qr_attendance/app.dart';
import 'package:smart_qr_attendance/core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sl.init();
  runApp(const SmartQrApp());
}
