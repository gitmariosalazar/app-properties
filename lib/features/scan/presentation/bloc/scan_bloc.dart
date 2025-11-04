// lib/features/scan/presentation/bloc/scan_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/scan/domain/usecases/scan_usecase.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ScanUseCase scanUseCase;

  ScanBloc({required this.scanUseCase}) : super(ScanInitial()) {
    on<StartScanEvent>(_onStartScan);
  }

  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanLoading());
    final result = await scanUseCase(NoParams());
    result.fold(
      (failure) => emit(ScanFailure('Scan failed')),
      (data) => emit(ScanSuccess(data)),
    );
  }
}
