import 'package:equatable/equatable.dart';
import 'package:app_properties/features/reading/domain/entities/reading.dart';

abstract class ReadingManuallyState extends Equatable {}

class ReadingManuallyInitial extends ReadingManuallyState {
  @override
  List<Object?> get props => [];
}

class ReadingManuallyLoading extends ReadingManuallyState {
  @override
  List<Object?> get props => [];
}

class ReadingManuallyLoaded extends ReadingManuallyState {
  final List<Reading> reading;

  ReadingManuallyLoaded(this.reading);

  @override
  List<Object?> get props => [reading];
}

class ReadingManuallyError extends ReadingManuallyState {
  final String message;

  ReadingManuallyError(this.message);

  @override
  List<Object?> get props => [message];
}
