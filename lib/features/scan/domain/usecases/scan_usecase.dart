// lib/features/scan/domain/usecases/scan_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/scan/domain/repositories/scan_repository.dart';

class ScanUseCase implements UseCase<String, NoParams> {
  final ScanRepository repository;

  ScanUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.scanQR();
  }
}
