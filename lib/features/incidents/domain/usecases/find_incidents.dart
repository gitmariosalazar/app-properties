import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentsParams {
  final String? connectionId;
  final String? status;
  final String? priority;
  final int? incidentTypeId;
  final int? sector;

  const FindIncidentsParams({
    this.connectionId,
    this.status,
    this.priority,
    this.incidentTypeId,
    this.sector,
  });
}

class FindIncidentsUseCase
    implements UseCase<List<IncidentDetailRowResponse>, FindIncidentsParams> {
  final IncidentRepository repository;

  FindIncidentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>> call(
    FindIncidentsParams params,
  ) {
    return repository.findIncidents(
      connectionId: params.connectionId,
      status: params.status,
      priority: params.priority,
      incidentTypeId: params.incidentTypeId,
      sector: params.sector,
    );
  }
}
