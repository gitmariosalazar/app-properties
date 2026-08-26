// lib/features/scan/presentation/blocs/reading_bloc.dart
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:app_properties/features/reading/domain/usecases/get_reading_info.dart';
import 'reading_scan_event.dart';
import 'reading_scan_state.dart';

class ReadingScanBloc extends Bloc<ReadingScanEvent, ReadingScanState> {
  final GetReadingInfo getReadingInfo;

  ReadingScanBloc(this.getReadingInfo) : super(ReadingScanInitial()) {
    on<LoadReadingScanInfo>(_onLoadReadingInfo);
    on<ResetReadingScan>(_onResetReadingScan);
  }

  Future<void> _onLoadReadingInfo(
    LoadReadingScanInfo event,
    Emitter<ReadingScanState> emit,
  ) async {
    emit(ReadingScanLoading());
    try {
      final reading = await getReadingInfo(event.cadastralKey);
      emit(ReadingScanLoaded(reading));
    } catch (e) {
      emit(ReadingScanError(e.toString()));
    }
  }

  void _onResetReadingScan(
    ResetReadingScan event,
    Emitter<ReadingScanState> emit,
  ) {
    emit(ReadingScanInitial());
  }
}
