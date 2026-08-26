import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/incidents/domain/usecases/get_incident_dashboard_kpis.dart';
import 'public_incident_kpis_state.dart';

class PublicIncidentKpisCubit extends Cubit<PublicIncidentKpisState> {
  final GetIncidentDashboardKpis getIncidentDashboardKpisUseCase;

  PublicIncidentKpisCubit({required this.getIncidentDashboardKpisUseCase})
    : super(PublicIncidentKpisInitial());

  Future<void> loadKpis() async {
    emit(PublicIncidentKpisLoading());
    final result = await getIncidentDashboardKpisUseCase();
    result.fold(
      (failure) => emit(PublicIncidentKpisError(failure.message)),
      (kpis) => emit(PublicIncidentKpisLoaded(kpis)),
    );
  }
}
