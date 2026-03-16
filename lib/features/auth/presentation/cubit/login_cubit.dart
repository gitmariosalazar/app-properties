import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(LoginInitial());

  Future<void> checkAuthStatus() async {
    final result = await checkAuthStatusUseCase(NoParams());
    result.fold(
      (_) => emit(LoginInitial()),
      (user) => emit(LoginSuccess(user)),
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
}
