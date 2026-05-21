// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/rendering.dart';

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
    } catch (e) {
      // Ignore remote logout failure, ensure local cleanup
    }
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Could not safe logout'));
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
    } catch (e) {
      return Left(CacheFailure(message: 'Error checking session'));
    }
  }
}
