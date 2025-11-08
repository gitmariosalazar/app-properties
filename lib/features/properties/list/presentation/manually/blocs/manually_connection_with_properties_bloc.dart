// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:app_properties/features/properties/list/domain/usecases/get_connection_with_properties.dart';

import 'manually_connection_with_properties_event.dart';
import 'manually_connection_with_properties_state.dart';

class ManuallyConnectionWithPropertiesBloc
    extends
        Bloc<
          ManuallyConnectionWithPropertiesEvent,
          ManuallyConnectionWithPropertiesState
        > {
  final GetConnectionWithProperties getConnectionWithProperties;

  ManuallyConnectionWithPropertiesBloc(this.getConnectionWithProperties)
    : super(ManuallyConnectionWithPropertiesInitial()) {
    on<FetchManuallyConnectionWithPropertiesEvent>(
      _onFetchConnectionWithPropertiesEvent,
    );
  }

  Future<void> _onFetchConnectionWithPropertiesEvent(
    FetchManuallyConnectionWithPropertiesEvent event,
    Emitter emit,
  ) async {
    emit(ManuallyConnectionWithPropertiesLoading());
    try {
      final connection = await getConnectionWithProperties(event.cadastralKey);
      emit(ManuallyConnectionWithPropertiesLoaded(connection));
    } catch (e) {
      emit(ManuallyConnectionWithPropertiesError(e.toString()));
    }
  }
}
