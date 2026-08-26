// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/entities/auth_response.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) {
    return repository.login(params.usernameOrEmail, params.password);
  }
}

class LoginParams {
  final String usernameOrEmail;
  final String password;

  LoginParams({required this.usernameOrEmail, required this.password});
}
