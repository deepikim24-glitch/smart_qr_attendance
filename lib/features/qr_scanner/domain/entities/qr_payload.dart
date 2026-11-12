import 'dart:convert';

import 'package:equatable/equatable.dart';

class QrPayload extends Equatable {
  const QrPayload({required this.sessionId, required this.token});

  final String sessionId;
  final String token;

  static QrPayload parse(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('QR payload must be a JSON object');
    }
    final sessionId = decoded['sessionId']?.toString();
    final token = decoded['token']?.toString();
    if (sessionId == null || sessionId.isEmpty || token == null || token.isEmpty) {
      throw const FormatException('QR payload is missing sessionId or token');
    }
    return QrPayload(sessionId: sessionId, token: token);
  }

  @override
  List<Object?> get props => [sessionId, token];
}
