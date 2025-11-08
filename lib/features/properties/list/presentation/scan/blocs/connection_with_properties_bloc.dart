// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:app_properties/features/properties/list/domain/usecases/get_connection_with_properties.dart';

import 'connection_with_properties_event.dart';
import 'connection_with_properties_state.dart';

class ConnectionWithPropertiesBloc
    extends Bloc<ConnectionWithPropertiesEvent, ConnectionWithPropertiesState> {
  final GetConnectionWithProperties getConnectionWithProperties;

  ConnectionWithPropertiesBloc(this.getConnectionWithProperties)
    : super(ConnectionWithPropertiesInitial()) {
    on<FetchConnectionWithPropertiesEvent>(
      _onFetchConnectionWithPropertiesEvent,
    );
  }

  Future<void> _onFetchConnectionWithPropertiesEvent(
    FetchConnectionWithPropertiesEvent event,
    Emitter emit,
  ) async {
    emit(ConnectionWithPropertiesLoading());
    try {
      final connection = await getConnectionWithProperties(event.cadastralKey);
      emit(ConnectionWithPropertiesLoaded(connection));
    } catch (e) {
      emit(ConnectionWithPropertiesError(e.toString()));
    }
  }
}
