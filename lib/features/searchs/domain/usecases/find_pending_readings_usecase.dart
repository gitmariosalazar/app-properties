import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';
import 'package:app_properties/features/searchs/domain/repositories/find-pending-readings.dart';

class FindPendingReadingsUseCase
    implements UseCase<List<PendingReadingResponse>, String> {
  final InterfaceSearchRepository searchRepository;

  FindPendingReadingsUseCase(this.searchRepository);

  @override
  Future<Either<Failure, List<PendingReadingResponse>>> call(
    String searchValue,
  ) {
    return searchRepository.findPendingReadingsByCadastralKeyOrCardIdAll(
      searchValue: searchValue,
    );
  }
}
