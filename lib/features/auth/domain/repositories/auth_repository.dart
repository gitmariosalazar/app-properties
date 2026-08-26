import 'package:app_properties/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';
import 'package:app_properties/features/auth/domain/entities/auth_response.dart';

/// Auth domain contract.
/// OCP: adding verifyUser does not break existing login/logout/checkAuthStatus callers.
abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(
    String usernameOrEmail,
    String password,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthResponse>> checkAuthStatus();
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);

  /// Verifies whether a user with the given identifier exists in the remote system.
  /// Used to guard token-cached sessions against deleted/deactivated accounts.
  Future<Either<Failure, VerifyUserResult>> verifyUser(String usernameOrEmail);

  Future<Either<Failure, void>> changePassword(
    String userId,
    ChangePasswordRequest request,
  );
}
