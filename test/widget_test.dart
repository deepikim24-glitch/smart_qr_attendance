import 'package:flutter_test/flutter_test.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/qr_scanner/domain/entities/qr_payload.dart';

void main() {
  test('QR payload parser reads sessionId and token', () {
    final payload = QrPayload.parse(
      '{"sessionId":"abc","token":"secret-token"}',
    );
    expect(payload.sessionId, 'abc');
    expect(payload.token, 'secret-token');
  });

  test('retry is allowed only for server and timeout failures', () {
    expect(const Failure('offline').canRetry, isTrue);
    expect(const Failure('timeout', statusCode: 408).canRetry, isTrue);
    expect(const Failure('server', statusCode: 500).canRetry, isTrue);
    expect(const Failure('conflict', statusCode: 409).canRetry, isFalse);
    expect(const Failure('bad request', statusCode: 400).canRetry, isFalse);
  });
}
