import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/list/domain/entities/connection.dart';

abstract class ConnectionWithPropertiesState extends Equatable {}

class ConnectionWithPropertiesInitial extends ConnectionWithPropertiesState {
  @override
  List<Object?> get props => [];
}

class ConnectionWithPropertiesLoading extends ConnectionWithPropertiesState {
  @override
  List<Object?> get props => [];
}

class ConnectionWithPropertiesLoaded extends ConnectionWithPropertiesState {
  final ConnectionEntity connection;

  ConnectionWithPropertiesLoaded(this.connection);

  @override
  List<Object?> get props => [connection];
}

class ConnectionWithPropertiesError extends ConnectionWithPropertiesState {
  final String message;

  ConnectionWithPropertiesError(this.message);

  @override
  List<Object?> get props => [message];
}
