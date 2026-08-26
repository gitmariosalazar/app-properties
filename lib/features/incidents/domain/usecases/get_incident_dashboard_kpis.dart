import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_kpi.model.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class GetIncidentDashboardKpis {
  final IncidentRepository repository;

  GetIncidentDashboardKpis(this.repository);

  Future<Either<Failure, IncidentDashboardKpiResponse>> call() async {
    return repository.getIncidentDashboardKpis();
  }
}
