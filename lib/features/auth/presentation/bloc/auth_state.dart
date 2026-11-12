part of 'auth_bloc.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? message,
    bool clearUser = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
