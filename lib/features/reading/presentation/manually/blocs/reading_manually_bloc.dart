import 'package:bloc/bloc.dart';
import 'package:app_properties/features/reading/domain/usecases/get_reading_info.dart';

import 'reading_manually_event.dart';
import 'reading_manually_state.dart';

class ReadingManuallyBloc
    extends Bloc<ReadingManuallyEvent, ReadingManuallyState> {
  final GetReadingInfo getReadingInfo;

  ReadingManuallyBloc(this.getReadingInfo) : super(ReadingManuallyInitial()) {
    on<LoadReadingManuallyInfo>(_onLoadReadingInfo);
  }

  Future<void> _onLoadReadingInfo(
    LoadReadingManuallyInfo event,
    Emitter<ReadingManuallyState> emit,
  ) async {
    emit(ReadingManuallyLoading());
    try {
      final reading = await getReadingInfo(event.cadastralKey);
      emit(ReadingManuallyLoaded(reading));
    } catch (e) {
      emit(ReadingManuallyError(e.toString()));
    }
  }
}
