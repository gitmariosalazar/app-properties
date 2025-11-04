// lib/features/scan/presentation/bloc/scan_event.dart
part of 'scan_bloc.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object> get props => [];
}

class StartScanEvent extends ScanEvent {}
