import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<User, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.checkAuthStatus();
  }
}
