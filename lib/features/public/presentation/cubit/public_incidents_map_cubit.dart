import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/incidents/domain/usecases/find_incidents.dart';
import 'public_incidents_map_state.dart';

class PublicIncidentsMapCubit extends Cubit<PublicIncidentsMapState> {
  final FindIncidentsUseCase findIncidentsUseCase;

  PublicIncidentsMapCubit(this.findIncidentsUseCase)
    : super(PublicIncidentsMapInitial());

  Future<void> loadMapIncidents({int? sector}) async {
    emit(PublicIncidentsMapLoading());

    // Obtenemos los incidentes con estado REPORTADO, ASIGNADO, EN_PROCESO, etc.
    // Como queremos mostrar todos los incidentes que tengan lat/lng, podríamos pedir sin filtros
    // O tal vez solo los pendientes. Depende del requerimiento. Pediremos todos.
    final result = await findIncidentsUseCase(FindIncidentsParams(sector: sector));

    result.fold((failure) => emit(PublicIncidentsMapError(failure.message)), (
      incidents,
    ) {
      // Filtrar solo los que tengan coordenadas válidas
      final mappedIncidents = incidents
          .where((i) => i.latitude != null && i.longitude != null)
          .toList();
      emit(PublicIncidentsMapLoaded(mappedIncidents));
    });
  }
}
