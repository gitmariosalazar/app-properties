import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_properties/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';
import 'package:dartz/dartz.dart';

class ChangePasswordUsecase {
  final AuthRepository repository;

  ChangePasswordUsecase({required this.repository});

  Future<Either<Failure, void>> call(
    String userId,
    ChangePasswordRequest request,
  ) async {
    return await repository.changePassword(userId, request);
  }
}
