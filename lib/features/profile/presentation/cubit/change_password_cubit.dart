import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';
import 'package:app_properties/features/auth/domain/usecases/change_password_usecase.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUsecase changePasswordUsecase;

  ChangePasswordCubit({required this.changePasswordUsecase})
    : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (newPassword != confirmNewPassword) {
      emit(const ChangePasswordFailure("Las contraseñas nuevas no coinciden"));
      return;
    }

    emit(ChangePasswordLoading());

    final request = ChangePasswordRequest(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    final result = await changePasswordUsecase(userId, request);

    result.fold(
      (failure) => emit(ChangePasswordFailure(failure.message)),
      (_) => emit(ChangePasswordSuccess()),
    );
  }
}
