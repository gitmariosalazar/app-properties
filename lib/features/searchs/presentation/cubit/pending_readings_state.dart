import 'package:equatable/equatable.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';

abstract class PendingReadingsState extends Equatable {
  const PendingReadingsState();

  @override
  List<Object?> get props => [];
}

class PendingReadingsInitial extends PendingReadingsState {}

class PendingReadingsLoading extends PendingReadingsState {}

class PendingReadingsLoaded extends PendingReadingsState {
  final List<PendingReadingResponse> readings;

  const PendingReadingsLoaded(this.readings);

  @override
  List<Object?> get props => [readings];
}

class PendingReadingsError extends PendingReadingsState {
  final String message;

  const PendingReadingsError(this.message);

  @override
  List<Object?> get props => [message];
}
