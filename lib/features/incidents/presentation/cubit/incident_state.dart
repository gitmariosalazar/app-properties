import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:equatable/equatable.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/incidents/domain/entities/incident.model.dart';

abstract class IncidentState extends Equatable {
  const IncidentState();

  @override
  List<Object?> get props => [];
}

class IncidentInitial extends IncidentState {}

class IncidentLoading extends IncidentState {}

/// State containing a list of incidents (e.g. for connection or general search)
class IncidentsLoaded extends IncidentState {
  final List<IncidentDetailRowResponse> incidents;

  const IncidentsLoaded(this.incidents);

  @override
  List<Object?> get props => [incidents];
}

/// State containing a single incident details
class IncidentDetailLoaded extends IncidentState {
  final IncidentModel incident;

  const IncidentDetailLoaded(this.incident);

  @override
  List<Object?> get props => [incident];
}

/// State containing the list of available categories
class IncidentCategoriesLoaded extends IncidentState {
  final List<IncidentCategoryModel> categories;

  const IncidentCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// State representing a successful write action (create or resolve)
class IncidentOperationSuccess extends IncidentState {
  final IncidentModel incident;
  final String message;

  const IncidentOperationSuccess({
    required this.incident,
    required this.message,
  });

  @override
  List<Object?> get props => [incident, message];
}

class IncidentError extends IncidentState {
  final String message;

  const IncidentError(this.message);

  @override
  List<Object?> get props => [message];
}
