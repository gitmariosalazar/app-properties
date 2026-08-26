import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:app_properties/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:app_properties/features/incidents/domain/usecases/create_incident.dart';
import 'package:app_properties/features/incidents/domain/usecases/resolve_incident.dart';
import 'package:app_properties/features/incidents/domain/usecases/find_incidents_by_connection.dart';
import 'package:app_properties/features/incidents/domain/usecases/find_incident_by_id.dart';
import 'package:app_properties/features/incidents/domain/usecases/find_incidents.dart';
import 'package:app_properties/features/incidents/domain/usecases/find_incident_categories.dart';
import 'incident_state.dart';

class IncidentCubit extends Cubit<IncidentState> {
  final CreateIncidentUseCase createIncidentUseCase;
  final ResolveIncidentUseCase resolveIncidentUseCase;
  final FindIncidentsByConnectionUseCase findIncidentsByConnectionUseCase;
  final FindIncidentByIdUseCase findIncidentByIdUseCase;
  final FindIncidentsUseCase findIncidentsUseCase;
  final FindIncidentCategoriesUseCase findIncidentCategoriesUseCase;

  IncidentCubit({
    required this.createIncidentUseCase,
    required this.resolveIncidentUseCase,
    required this.findIncidentsByConnectionUseCase,
    required this.findIncidentByIdUseCase,
    required this.findIncidentsUseCase,
    required this.findIncidentCategoriesUseCase,
  }) : super(IncidentInitial());

  Future<void> createIncident({required CreateIncidentRequest request}) async {
    emit(IncidentLoading());
    final result = await createIncidentUseCase(request);

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (newIncident) => emit(
        IncidentOperationSuccess(
          incident: newIncident,
          message: 'Incidente registrado exitosamente.',
        ),
      ),
    );
  }

  Future<void> resolveIncident({
    required String incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  }) async {
    emit(IncidentLoading());
    final result = await resolveIncidentUseCase(
      ResolveIncidentParams(
        incidentId: incidentId,
        resolverUserId: resolverUserId,
        request: request,
      ),
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (resolvedIncident) => emit(
        IncidentOperationSuccess(
          incident: resolvedIncident,
          message: 'Incidente resuelto exitosamente.',
        ),
      ),
    );
  }

  Future<void> loadIncidentsByConnection(String connectionId) async {
    emit(IncidentLoading());
    final result = await findIncidentsByConnectionUseCase(connectionId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incidents) => emit(IncidentsLoaded(incidents)),
    );
  }

  Future<void> loadIncidentById(String incidentId) async {
    emit(IncidentLoading());
    final result = await findIncidentByIdUseCase(incidentId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incident) => emit(IncidentDetailLoaded(incident)),
    );
  }

  Future<void> loadIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
    int? sector,
  }) async {
    emit(IncidentLoading());
    final result = await findIncidentsUseCase(
      FindIncidentsParams(
        connectionId: connectionId,
        status: status,
        priority: priority,
        incidentTypeId: incidentTypeId,
        sector: sector,
      ),
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incidents) => emit(IncidentsLoaded(incidents)),
    );
  }

  Future<void> loadIncidentCategories() async {
    emit(IncidentLoading());
    final result = await findIncidentCategoriesUseCase(NoParams());

    if (isClosed) return;

    if (isClosed) return;
    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (categories) => emit(IncidentCategoriesLoaded(categories)),
    );
  }
}
