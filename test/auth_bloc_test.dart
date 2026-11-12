import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_qr_attendance/core/errors/failures.dart';
import 'package:smart_qr_attendance/features/auth/domain/entities/user_entity.dart';
import 'package:smart_qr_attendance/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_qr_attendance/features/auth/domain/usecases/auth_usecases.dart';
import 'package:smart_qr_attendance/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthBloc bloc;

  const user = UserEntity(
    id: '1',
    name: 'Jane',
    email: 'employee@company.com',
    role: 'employee',
  );

  setUp(() {
    repository = MockAuthRepository();
    bloc = AuthBloc(
      loginUseCase: LoginUseCase(repository),
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
    );
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'emits authenticated on successful login',
    build: () {
      when(() => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const AuthSession(user: user, token: 'jwt'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(email: 'employee@company.com', password: 'Employee@12345'),
    ),
    expect: () => [
      const AuthState(status: AuthStatus.authenticating),
      const AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits failure on invalid credentials',
    build: () {
      when(() => repository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const Failure('Invalid email or password', statusCode: 401));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(email: 'employee@company.com', password: 'wrong'),
    ),
    expect: () => [
      const AuthState(status: AuthStatus.authenticating),
      const AuthState(status: AuthStatus.failure, message: 'Invalid email or password'),
    ],
  );
}
