// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';

/// Auth domain contract.
/// OCP: adding verifyUser does not break existing login/logout/checkAuthStatus callers.
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String usernameOrEmail, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> checkAuthStatus();

  /// Verifies whether a user with the given identifier exists in the remote system.
  /// Used to guard token-cached sessions against deleted/deactivated accounts.
  Future<Either<Failure, VerifyUserResult>> verifyUser(String usernameOrEmail);
}
