// lib/features/scan/data/repositories/scan_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/scan/data/datasources/scan_datasource.dart';
import 'package:app_properties/features/scan/domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanDataSource dataSource;

  ScanRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> scanQR() async {
    try {
      final result = await dataSource.scanQR();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
