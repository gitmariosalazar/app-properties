import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/auth/domain/entities/auth_response.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase
    implements UseCase<AuthResponse, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponse>> call(
    RefreshTokenParams params,
  ) async {
    return await repository.refreshToken(params.refreshToken);
  }
}

class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});
}
