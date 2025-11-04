// lib/features/form/presentation/blocs/photo_reading_state.dart
import 'package:app_properties/features/form/domain/entities/photo_reading_entity.dart';
import 'dart:io';

abstract class PhotoReadingState {}

class PhotoReadingInitial extends PhotoReadingState {
  final List<File>? selectedImages;

  PhotoReadingInitial({this.selectedImages});
}

class PhotoReadingLoading extends PhotoReadingState {}

class PhotoReadingSuccess extends PhotoReadingState {
  final List<PhotoReadingEntity> photoReadings;

  PhotoReadingSuccess(this.photoReadings);
}

class PhotoReadingError extends PhotoReadingState {
  final String message;

  PhotoReadingError(this.message);
}

class PhotoReadingImagesSelected extends PhotoReadingState {
  final List<File> images;

  PhotoReadingImagesSelected(this.images);
}
