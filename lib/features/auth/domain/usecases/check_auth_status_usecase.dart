import 'package:app_properties/features/auth/domain/entities/auth_response.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<AuthResponse, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(NoParams params) {
    return repository.checkAuthStatus();
  }
}
