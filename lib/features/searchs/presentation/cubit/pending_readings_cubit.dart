import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/searchs/domain/usecases/find_pending_readings_usecase.dart';
import 'pending_readings_state.dart';

class PendingReadingsCubit extends Cubit<PendingReadingsState> {
  final FindPendingReadingsUseCase findPendingReadingsUseCase;

  PendingReadingsCubit({required this.findPendingReadingsUseCase})
    : super(PendingReadingsInitial());

  Future<void> searchPendingReadings(String searchValue) async {
    if (searchValue.trim().isEmpty) {
      emit(
        const PendingReadingsError("El valor de búsqueda no puede estar vacío"),
      );
      return;
    }

    emit(PendingReadingsLoading());
    final result = await findPendingReadingsUseCase(searchValue.trim());

    if (isClosed) return;

    result.fold(
      (failure) => emit(PendingReadingsError(failure.message)),
      (readings) => emit(PendingReadingsLoaded(readings)),
    );
  }

  void resetSearch() {
    emit(PendingReadingsInitial());
  }
}
