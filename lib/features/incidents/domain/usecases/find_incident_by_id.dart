import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/entities/incident.model.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentByIdUseCase implements UseCase<IncidentModel, String> {
  final IncidentRepository repository;

  FindIncidentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentModel>> call(String incidentId) {
    return repository.findById(incidentId);
  }
}
