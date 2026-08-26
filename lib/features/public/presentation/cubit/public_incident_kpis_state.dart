import 'package:equatable/equatable.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_kpi.model.dart';

abstract class PublicIncidentKpisState extends Equatable {
  const PublicIncidentKpisState();

  @override
  List<Object> get props => [];
}

class PublicIncidentKpisInitial extends PublicIncidentKpisState {}

class PublicIncidentKpisLoading extends PublicIncidentKpisState {}

class PublicIncidentKpisLoaded extends PublicIncidentKpisState {
  final IncidentDashboardKpiResponse data;

  const PublicIncidentKpisLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class PublicIncidentKpisError extends PublicIncidentKpisState {
  final String message;

  const PublicIncidentKpisError(this.message);

  @override
  List<Object> get props => [message];
}
