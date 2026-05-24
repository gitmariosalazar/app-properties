import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

/// Parameters required by [VerifyUserUseCase].
class VerifyUserParams {
  final String usernameOrEmail;
  const VerifyUserParams({required this.usernameOrEmail});
}

/// Verifies whether a given username or email exists in the remote system.
///
/// SRP : one responsibility — check existence, nothing else.
/// DIP : depends on [AuthRepository] abstraction, not on a concrete class.
/// OCP : [LoginUseCase] and [CheckAuthStatusUseCase] are untouched.
class VerifyUserUseCase implements UseCase<VerifyUserResult, VerifyUserParams> {
  final AuthRepository repository;

  VerifyUserUseCase(this.repository);

  @override
  Future<Either<Failure, VerifyUserResult>> call(VerifyUserParams params) {
    return repository.verifyUser(params.usernameOrEmail);
  }
}
