import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';

abstract class InterfaceSearchRepository {
  Future<Either<Failure, List<PendingReadingResponse>>>
  findPendingReadingsByCadastralKeyOrCardIdAll({required String searchValue});
}
