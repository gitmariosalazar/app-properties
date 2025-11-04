part of 'manually_bloc.dart';

abstract class ManuallyEvent {}

class StartManuallyEvent extends ManuallyEvent {
  final String connectionId;

  StartManuallyEvent(this.connectionId);

  List<Object> get props => [connectionId];
}
