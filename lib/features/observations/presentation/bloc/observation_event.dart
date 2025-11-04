part of 'observation_bloc.dart';

abstract class ObservationEvent {}

class FindAllObservationsEvent extends ObservationEvent {
  FindAllObservationsEvent();
}

class FindObservationsByCadastralKeyEvent extends ObservationEvent {
  final String connectionId;
  FindObservationsByCadastralKeyEvent(this.connectionId);
}
