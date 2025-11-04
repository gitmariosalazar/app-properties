import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/manually/data/datasources/manually_datasource.dart';
import 'package:app_properties/features/manually/domain/repositories/manually_repository.dart';

class ManuallyRepositoryImpl implements ManuallyRepository {
  final ManuallyDataSource dataSource;

  ManuallyRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchReading(
    String connectionId,
  ) async {
    try {
      final data = await dataSource.fetchReading(connectionId);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
