import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/verify_user_usecase.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';

/// Cubit that orchestrates the full authentication lifecycle.
///
/// SRP : owns only auth state transitions.
/// DIP : depends on use case abstractions, never on data-layer classes.
///
/// ── checkAuthStatus decision tree ─────────────────────────────────────────
///
///   Cache empty             → [LoginInitial]  (go to login)
///   Cache found, then:
///     NetworkFailure        → [LoginSuccess]  (keep session, work offline)
///     ServerFailure (other) → [LoginInitial]  (force re-login, clear cache)
///     exists == true        → [LoginSuccess]  (normal session restore)
///     exists == false       → [LoginUserNotFound] (account deleted/inactive)
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final VerifyUserUseCase verifyUserUseCase;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.verifyUserUseCase,
  }) : super(LoginInitial());

  /// Two-step session restore:
  ///  1. Read local cache → if empty, go to login.
  ///  2. Verify cached user against backend.
  ///     - If offline (NetworkFailure) → keep session (offline mode).
  ///     - If server error → clear session, force re-login.
  ///     - If user confirmed → restore session.
  ///     - If user deleted/inactive → clear session, show message.
  Future<void> checkAuthStatus() async {
    // Step 1: local cache
    final localResult = await checkAuthStatusUseCase(NoParams());

    await localResult.fold(
      (_) async => emit(LoginInitial()),

      (user) async {
        // Step 2: remote verify
        final verifyResult = await verifyUserUseCase(
          VerifyUserParams(usernameOrEmail: user.username),
        );

        verifyResult.fold(
          (failure) {
            if (failure is NetworkFailure) {
              // ✅ No internet — keep cached session, work offline
              emit(LoginSuccess(user));
            } else {
              // ⛔ Server error (unexpected) → force re-login
              _clearLocalSession();
              emit(LoginInitial());
            }
          },

          (verifyData) {
            if (verifyData.exists) {
              // ✅ User confirmed in backend → restore session
              emit(LoginSuccess(user));
            } else {
              // ⛔ User deleted or deactivated → clear session, notify user
              _clearLocalSession();
              emit(
                const LoginUserNotFound(
                  'Tu cuenta ya no existe o fue desactivada. '
                  'Por favor inicia sesión nuevamente.',
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> login(String usernameOrEmail, String password) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(usernameOrEmail: usernameOrEmail, password: password),
    );
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user)),
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

  /// Clears local cache silently — fire-and-forget, errors swallowed.
  void _clearLocalSession() {
    logoutUseCase(NoParams()).ignore();
  }
}
