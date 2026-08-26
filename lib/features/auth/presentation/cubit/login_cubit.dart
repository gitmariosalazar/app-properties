import 'dart:convert';
import 'package:app_properties/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';

/// Cubit that orchestrates the full authentication lifecycle.
///
/// ── checkAuthStatus decision tree ─────────────────────────────────────────
///
///   Cache empty             → [LoginInitial]     (go to login)
///   Cache found, then:
///     NetworkFailure        → [LoginSuccess]     (keep session, work offline) ✅ FIX
///     ServerFailure (other) → [LoginInitial]     (force re-login)
///     exists == true        → [LoginSuccess]     (normal session restore)
///     exists == false       → [LoginUserNotFound] (account deleted/inactive)
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.refreshTokenUseCase,
  }) : super(LoginInitial());

  bool _isTokenValid(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      String output = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (output.length % 4) {
        case 0:
          break;
        case 2:
          output += '==';
          break;
        case 3:
          output += '=';
          break;
        default:
          return false;
      }

      final payloadString = utf8.decode(base64Url.decode(output));
      final payloadMap = json.decode(payloadString);

      if (payloadMap is! Map<String, dynamic>) return false;

      if (payloadMap.containsKey('exp')) {
        final exp = payloadMap['exp'] as int;
        // Margen de 1 minuto para evitar expiraciones en tránsito
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(
          exp * 1000,
        ).subtract(const Duration(minutes: 1));
        return DateTime.now().isBefore(expiryDate);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    final localResult = await checkAuthStatusUseCase(NoParams());

    await localResult.fold((_) async => emit(LoginInitial()), (
      authResponse,
    ) async {
      // Si el token de acceso sigue siendo válido, no es necesario refrescarlo
      if (_isTokenValid(authResponse.accessToken)) {
        emit(LoginSuccess(authResponse.user, authResponse.accessToken));
        return;
      }

      // If there's no refresh token, we can't refresh
      if (authResponse.refreshToken.isEmpty) {
        _clearLocalSession();
        emit(LoginInitial());
        return;
      }

      final refreshResult = await refreshTokenUseCase(
        RefreshTokenParams(refreshToken: authResponse.refreshToken),
      );

      refreshResult.fold(
        (failure) {
          if (failure is NetworkFailure) {
            // ✅ No internet — keep cached session, work offline
            emit(LoginSuccess(authResponse.user, authResponse.accessToken));
          } else {
            // ⛔ Token expired or invalid → force re-login
            _clearLocalSession();
            emit(LoginInitial());
          }
        },
        (newAuthData) {
          // ✅ Token refreshed successfully
          emit(LoginSuccess(newAuthData.user, newAuthData.accessToken));
        },
      );
    });
  }

  Future<void> login(String usernameOrEmail, String password) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(usernameOrEmail: usernameOrEmail, password: password),
    );

    print('✅✅✅✅✅✅ Token Login Cubit: ${result}');
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (authResponse) =>
          emit(LoginSuccess(authResponse.user, authResponse.accessToken)),
    );
  }

  Future<void> logout() async {
    emit(LoginLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginInitial()),
    );
  }

  void _clearLocalSession() {
    logoutUseCase(NoParams()).ignore();
  }
}
