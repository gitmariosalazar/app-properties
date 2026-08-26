// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/services/websocket_service.dart';
import 'package:app_properties/features/auth/domain/entities/auth_response.dart';
import 'package:app_properties/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_properties/features/auth/domain/entities/verify_user_result.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final WebSocketService webSocketService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.webSocketService,
  });

  @override
  Future<Either<Failure, AuthResponse>> login(
    String username_or_email,
    String password,
  ) async {
    try {
      final authResponse = await remoteDataSource.login(
        username_or_email,
        password,
      );
      debugPrint('AuthResponse: $authResponse');

      // Validar si el usuario tiene el rol permitido para usar esta aplicación móvil.
      final hasAccess = authResponse.user.roles.any((role) {
        final upperRole = role.name.toUpperCase();
        return upperRole == 'SUPER ADMINISTRADOR' || upperRole == 'EMPLEADO';
      });

      if (!hasAccess) {
        // No almacenamos el token ni sesión si no tiene el rol necesario.
        return Left(
          ServerFailure(
            message:
                'Acceso denegado. Esta aplicación es exclusiva para los usuarios internos de la EPAA-AA.',
          ),
        );
      }

      await localDataSource.cacheToken(authResponse.accessToken);
      await localDataSource.cacheUser(authResponse.user);

      webSocketService.disconnect();
      webSocketService.connect(
        Environment.apiUrl,
        token: authResponse.accessToken,
      );
      print('✅✅✅✅✅✅ Token Repository Impl: ${authResponse.accessToken}');
      print('✅✅✅✅✅✅ URL Repository Impl: ${Environment.apiUrl}');

      return Right<Failure, AuthResponse>(authResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final authResponse = await remoteDataSource.refreshToken(refreshToken);
      debugPrint('RefreshTokenResponse: $authResponse');

      await localDataSource.cacheToken(authResponse.accessToken);
      await localDataSource.cacheUser(authResponse.user);

      // Update WebSocket with new token
      webSocketService.disconnect();
      webSocketService.connect(
        Environment.apiUrl,
        token: authResponse.accessToken,
      );

      return Right<Failure, AuthResponse>(authResponse);
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
    webSocketService.disconnect();

    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout failure
    }
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure(message: 'Could not safe logout'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      final authResponse = await localDataSource.getAuthResponse();
      if (token != null && token.isNotEmpty && authResponse != null) {
        return Right<Failure, AuthResponse>(authResponse);
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

  @override
  Future<Either<Failure, void>> changePassword(
    String userId,
    ChangePasswordRequest request,
  ) async {
    try {
      await remoteDataSource.changePassword(userId, request);
      return Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
