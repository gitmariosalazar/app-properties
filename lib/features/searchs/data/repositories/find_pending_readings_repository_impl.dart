import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/searchs/data/datasources/find_pending_readings_datasorce.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';
import 'package:app_properties/features/searchs/domain/repositories/find-pending-readings.dart';

class FindPendingReadingsRepositoryImpl implements InterfaceSearchRepository {
  final IFindPendingReadingsDatasource remoteDataSource;

  FindPendingReadingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PendingReadingResponse>>>
  findPendingReadingsByCadastralKeyOrCardIdAll({
    required String searchValue,
  }) async {
    try {
      final result = await remoteDataSource
          .findPendingReadingsByCadastralKeyOrCardIdAll(searchValue);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error inesperado al buscar lecturas pendientes: $e',
        ),
      );
    }
  }
}
