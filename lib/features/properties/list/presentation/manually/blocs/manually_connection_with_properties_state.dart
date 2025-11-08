import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/list/domain/entities/connection.dart';

abstract class ManuallyConnectionWithPropertiesState extends Equatable {}

class ManuallyConnectionWithPropertiesInitial
    extends ManuallyConnectionWithPropertiesState {
  @override
  List<Object?> get props => [];
}

class ManuallyConnectionWithPropertiesLoading
    extends ManuallyConnectionWithPropertiesState {
  @override
  List<Object?> get props => [];
}

class ManuallyConnectionWithPropertiesLoaded
    extends ManuallyConnectionWithPropertiesState {
  final ConnectionEntity connection;

  ManuallyConnectionWithPropertiesLoaded(this.connection);

  @override
  List<Object?> get props => [connection];
}

class ManuallyConnectionWithPropertiesError
    extends ManuallyConnectionWithPropertiesState {
  final String message;

  ManuallyConnectionWithPropertiesError(this.message);

  @override
  List<Object?> get props => [message];
}
