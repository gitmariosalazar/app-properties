// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Error taxonomy:
///   [NetworkFailure]  → device offline / server unreachable (SocketException)
///   [ServerFailure]   → server responded with an error (4xx, 5xx)
///   [CacheFailure]    → local SharedPreferences error
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(
    String usernameOrEmail,
    String password,
  ) async {
    try {
      final authResponse = await remoteDataSource.login(
        usernameOrEmail,
        password,
      );
      debugPrint('AuthResponse: $authResponse');
      await localDataSource.cacheToken(authResponse.accessToken);
      await localDataSource.cacheUser(authResponse.user);
      return Right(authResponse.user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout failure — local cleanup always runs
    }
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure(message: 'Could not complete logout'));
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      final user = await localDataSource.getUser();
      if (token != null && token.isNotEmpty && user != null) {
        return Right(user);
      }
      return Left(CacheFailure(message: 'No active session'));
    } catch (_) {
      return Left(CacheFailure(message: 'Error checking session'));
    }
  }

  @override
  Future<Either<Failure, VerifyUserResult>> verifyUser(
    String usernameOrEmail,
  ) async {
    try {
      final result = await remoteDataSource.verifyUser(usernameOrEmail);
      // Treat inactive accounts as non-existent for security
      if (!result.exists || result.isActive == false) {
        return Right(
          VerifyUserResult(
            exists: false,
            userId: result.userId,
            username: result.username,
            email: result.email,
            isActive: result.isActive,
          ),
        );
      }
      return Right(result);
    } on NetworkException catch (e) {
      // Device is offline — propagate as NetworkFailure so the cubit
      // can keep the session alive instead of clearing it.
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
