// lib/features/scan/presentation/bloc/scan_state.dart
part of 'scan_bloc.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final String data;

  const ScanSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class ScanFailure extends ScanState {
  final String message;

  const ScanFailure(this.message);

  @override
  List<Object> get props => [message];
}
