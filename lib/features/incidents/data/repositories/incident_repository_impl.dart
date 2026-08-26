import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_kpi.model.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/incidents/data/datasources/incident_remote_datasource.dart';
import 'package:app_properties/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:app_properties/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/incidents/domain/entities/incident.model.dart';
import 'package:app_properties/features/incidents/domain/repositories/incident_repository.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource remoteDataSource;

  IncidentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, IncidentModel>> createIncident({
    required CreateIncidentRequest request,
  }) async {
    try {
      final result = await remoteDataSource.createIncident(request: request);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al registrar el incidente: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, IncidentModel>> resolveIncident({
    required String incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  }) async {
    try {
      final result = await remoteDataSource.resolveIncident(
        incidentId: incidentId,
        resolverUserId: resolverUserId,
        request: request,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al resolver el incidente: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>>
  findIncidentsByConnection(String connectionId) async {
    try {
      final list = await remoteDataSource.findIncidentsByConnection(
        connectionId,
      );
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al buscar incidentes de la conexión: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, IncidentModel>> findById(String incidentId) async {
    try {
      final incident = await remoteDataSource.findById(incidentId);
      return Right(incident);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al buscar el incidente por ID: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>> findIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
    int? sector,
  }) async {
    try {
      final list = await remoteDataSource.findIncidents(
        connectionId: connectionId,
        status: status,
        priority: priority,
        incidentTypeId: incidentTypeId,
        sector: sector,
      );
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al filtrar incidentes: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IncidentCategoryModel>>>
  findIncidentCategories() async {
    try {
      final categories = await remoteDataSource.findIncidentCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al obtener categorías de incidentes: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, IncidentDashboardKpiResponse>>
  getIncidentDashboardKpis() async {
    try {
      final kpis = await remoteDataSource.getIncidentDashboardKpis();
      return Right(kpis);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
