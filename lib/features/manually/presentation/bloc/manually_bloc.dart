import 'package:app_properties/features/manually/domain/usecases/manually_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manually_event.dart';
part 'manually_state.dart';

class ManuallyBloc extends Bloc<ManuallyEvent, ManuallyState> {
  final ManuallyUseCase manuallyUseCase;

  ManuallyBloc(this.manuallyUseCase) : super(ManuallyInitial()) {
    on<StartManuallyEvent>(_onStartManually);
  }

  Future<void> _onStartManually(
    StartManuallyEvent event,
    Emitter<ManuallyState> emit,
  ) async {
    emit(ManuallyLoading());
    try {
      final result = await manuallyUseCase(event.connectionId);
      result.fold(
        (failure) => emit(ManuallyFailure("No se pudieron cargar los datos")),
        (data) => emit(ManuallyLoaded(data)),
      );
    } catch (e) {
      emit(ManuallyFailure("Error al cargar los datos: $e"));
    }
  }
}
