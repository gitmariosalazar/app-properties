import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_kpi.model.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:app_properties/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/incidents/domain/entities/incident.model.dart';

/// Repository interface for Incident operations.
/// Follows LSP (Liskov Substitution Principle) and ISP (Interface Segregation Principle).
abstract class IncidentRepository {
  Future<Either<Failure, IncidentModel>> createIncident({
    required CreateIncidentRequest request,
  });

  Future<Either<Failure, IncidentModel>> resolveIncident({
    required String incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  });

  Future<Either<Failure, List<IncidentDetailRowResponse>>>
  findIncidentsByConnection(String connectionId);

  Future<Either<Failure, IncidentModel>> findById(String incidentId);

  Future<Either<Failure, List<IncidentDetailRowResponse>>> findIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
    int? sector,
  });

  Future<Either<Failure, List<IncidentCategoryModel>>> findIncidentCategories();
  Future<Either<Failure, IncidentDashboardKpiResponse>>
  getIncidentDashboardKpis();
}
