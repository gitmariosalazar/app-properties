// lib/features/form/presentation/blocs/photo_reading_bloc.dart
import 'package:app_properties/features/form/domain/usecases/create_photo_reading_use_case.dart';

import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_event.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoReadingBloc extends Bloc<PhotoReadingEvent, PhotoReadingState> {
  final CreatePhotoReadingUseCase useCase;

  PhotoReadingBloc(this.useCase) : super(PhotoReadingInitial()) {
    // Manejar selección de imágenes
    on<SelectImagesEvent>((event, emit) {
      if (event.images.isEmpty) {
        emit(PhotoReadingError('Please select at least one image.'));
      } else {
        emit(PhotoReadingImagesSelected(event.images));
      }
    });

    // Manejar creación de lecturas de fotos
    on<CreatePhotoReadingEvent>((event, emit) async {
      emit(PhotoReadingLoading());
      final params = CreatePhotoReadingParams(
        images: event.images,
        readingId: event.readingId,
        cadastralKey: event.cadastralKey,
        description: event.description,
      );

      // Validación básica antes de la llamada al use case
      if (params.images.isEmpty) {
        emit(PhotoReadingError('No images selected for upload.'));
        return;
      }
      if (params.readingId <= 0) {
        emit(PhotoReadingError('Invalid Reading ID.'));
        return;
      }
      if (params.cadastralKey.isEmpty) {
        emit(PhotoReadingError('Cadastral Key is required.'));
        return;
      }

      final result = await useCase(params);
      result.fold(
        (failure) => emit(PhotoReadingError(failure.message)),
        (photoReadings) => emit(PhotoReadingSuccess(photoReadings)),
      );
    });

    // Manejar limpieza del estado
    on<ClearPhotoReadingEvent>((event, emit) {
      emit(PhotoReadingInitial());
    });
  }
}
