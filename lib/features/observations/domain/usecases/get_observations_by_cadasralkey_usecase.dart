import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/observations/domain/entities/observation_entity.dart';
import 'package:app_properties/features/observations/domain/repositories/observation_repository.dart';

class FindAllObservationsByCadastralKeyUseCase
    implements UseCase<List<ObservationEntity>, ObservationParams> {
  final ObservationRepository repository;

  FindAllObservationsByCadastralKeyUseCase(this.repository);

  @override
  Future<Either<Failure, List<ObservationEntity>>> call(
    ObservationParams params,
  ) {
    return repository.findObservationsByCadastralKey(params.connectionId);
  }
}

class ObservationParams {
  final String connectionId;

  ObservationParams({required this.connectionId});
}
