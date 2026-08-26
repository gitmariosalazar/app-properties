import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:app_properties/features/incidents/domain/entities/incident.model.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class CreateIncidentUseCase
    implements UseCase<IncidentModel, CreateIncidentRequest> {
  final IncidentRepository repository;

  CreateIncidentUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentModel>> call(CreateIncidentRequest params) {
    return repository.createIncident(request: params);
  }
}
