import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _restoreSessionUseCase = restoreSessionUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onExpired);
  }

  final LoginUseCase _loginUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await _restoreSessionUseCase();
      if (user == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on Failure catch (failure) {
      await _logoutUseCase();
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        message: failure.isUnauthorized ? null : failure.message,
      ));
    }
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearMessage: true));
    try {
      final session = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: session.user));
    } on Failure catch (failure) {
      emit(AuthState(status: AuthStatus.failure, message: failure.message));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase();
    emit(const AuthState(
      status: AuthStatus.unauthenticated,
      message: 'Your session has expired. Please sign in again.',
    ));
  }
}
