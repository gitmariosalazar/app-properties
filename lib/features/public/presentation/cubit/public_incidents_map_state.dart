import 'package:equatable/equatable.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:app_properties/config/environments/environment.dart';

abstract class PublicIncidentsMapState extends Equatable {
  const PublicIncidentsMapState();

  @override
  List<Object> get props => [];
}

class PublicIncidentsMapInitial extends PublicIncidentsMapState {}

class PublicIncidentsMapLoading extends PublicIncidentsMapState {}

class PublicIncidentsMapLoaded extends PublicIncidentsMapState {
  final List<IncidentDetailRowResponse> incidents;
  final MapProviderConfig mapConfig;

  const PublicIncidentsMapLoaded(this.incidents, this.mapConfig);

  @override
  List<Object> get props => [incidents, mapConfig];
}

class PublicIncidentsMapError extends PublicIncidentsMapState {
  final String message;

  const PublicIncidentsMapError(this.message);

  @override
  List<Object> get props => [message];
}
