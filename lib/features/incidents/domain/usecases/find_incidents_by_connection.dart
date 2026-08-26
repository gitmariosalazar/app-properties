import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentsByConnectionUseCase
    implements UseCase<List<IncidentDetailRowResponse>, String> {
  final IncidentRepository repository;

  FindIncidentsByConnectionUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>> call(
    String connectionId,
  ) {
    return repository.findIncidentsByConnection(connectionId);
  }
}
