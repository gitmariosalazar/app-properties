import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/observations/domain/entities/observation_entity.dart';

abstract class ObservationRepository {
  Future<Either<Failure, List<ObservationEntity>>> findAllObservations();
  Future<Either<Failure, List<ObservationEntity>>>
  findObservationsByCadastralKey(String connectionId);
}
