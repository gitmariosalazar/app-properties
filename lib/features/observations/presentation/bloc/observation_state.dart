part of 'observation_bloc.dart';

abstract class ObservationState extends Equatable {
  const ObservationState();

  @override
  List<Object?> get props => [];
}

class ObservationInitial extends ObservationState {}

class ObservationLoading extends ObservationState {}

class ObservationError extends ObservationState {
  final String message;
  const ObservationError(this.message);

  @override
  List<Object?> get props => [message];
}

class FindAllObservationLoaded extends ObservationState {
  final List<ObservationEntity> observation;
  const FindAllObservationLoaded(this.observation);

  @override
  List<Object?> get props => [observation];
}

class GetObservationByCadastralKeyListLoaded extends ObservationState {
  final List<ObservationEntity> observations;
  const GetObservationByCadastralKeyListLoaded(this.observations);

  @override
  List<Object?> get props => [observations];
}
