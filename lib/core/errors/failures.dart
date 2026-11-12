import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  const Failure(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get canRetry =>
      statusCode == null || statusCode == 408 || statusCode! >= 500;

  @override
  List<Object?> get props => [message, code, statusCode];
}
