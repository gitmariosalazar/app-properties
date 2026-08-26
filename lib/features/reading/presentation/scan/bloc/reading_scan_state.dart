// lib/features/scan/presentation/blocs/reading_state.dart
import 'package:equatable/equatable.dart';
import 'package:app_properties/features/reading/domain/entities/reading.dart';

abstract class ReadingScanState extends Equatable {}

class ReadingScanInitial extends ReadingScanState {
  @override
  List<Object?> get props => [];
}

class ReadingScanLoading extends ReadingScanState {
  @override
  List<Object?> get props => [];
}

class ReadingScanLoaded extends ReadingScanState {
  final List<Reading> reading;
  ReadingScanLoaded(this.reading);
  @override
  List<Object?> get props => [reading];
}

class ReadingScanError extends ReadingScanState {
  final String message;
  ReadingScanError(this.message);
  @override
  List<Object?> get props => [message];
}
