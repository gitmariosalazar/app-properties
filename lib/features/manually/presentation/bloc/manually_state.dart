part of 'manually_bloc.dart';

abstract class ManuallyState {
  List<Object> get props => [];
}

class ManuallyInitial extends ManuallyState {
  @override
  List<Object> get props => [];
}

class ManuallyLoading extends ManuallyState {
  @override
  List<Object> get props => [];
}

class ManuallyLoaded extends ManuallyState {
  final Map<String, dynamic> data;

  ManuallyLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class ManuallyFailure extends ManuallyState {
  final String message;

  ManuallyFailure(this.message);

  @override
  List<Object> get props => [message];
}
