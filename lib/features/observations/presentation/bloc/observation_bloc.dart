import 'package:app_properties/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:equatable/equatable.dart';
import 'package:app_properties/features/observations/domain/entities/observation_entity.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 👇 Aquí declaras las partes
part 'observation_event.dart';
part 'observation_state.dart';

class ObservationBloc extends Bloc<ObservationEvent, ObservationState> {
  final FindAllObservationsUseCase findAllObservationsUseCase;
  final FindAllObservationsByCadastralKeyUseCase findByCadastralKeyUseCase;

  ObservationBloc(
    this.findAllObservationsUseCase,
    this.findByCadastralKeyUseCase,
  ) : super(ObservationInitial()) {
    on<FindAllObservationsEvent>((event, emit) async {
      emit(ObservationLoading());
      final result = await findAllObservationsUseCase(NoParams());

      result.fold(
        (failure) => emit(ObservationError(failure.toString())),
        (observation) => emit(FindAllObservationLoaded(observation)),
      );
    });

    on<FindObservationsByCadastralKeyEvent>((event, emit) async {
      emit(ObservationLoading());
      final result = await findByCadastralKeyUseCase(
        ObservationParams(connectionId: event.connectionId),
      );
      result.fold(
        (failure) => emit(ObservationError(failure.toString())),
        (observations) =>
            emit(GetObservationByCadastralKeyListLoaded(observations)),
      );
    });
  }
}
