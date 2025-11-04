// lib/features/form/presentation/blocs/photo_reading_event.dart
import 'dart:io';

abstract class PhotoReadingEvent {}

class SelectImagesEvent extends PhotoReadingEvent {
  final List<File> images;

  SelectImagesEvent(this.images);
}

class CreatePhotoReadingEvent extends PhotoReadingEvent {
  final List<File> images;
  final int readingId;
  final String cadastralKey;
  final String? description;

  CreatePhotoReadingEvent({
    required this.images,
    required this.readingId,
    required this.cadastralKey,
    this.description,
  });
}

class ClearPhotoReadingEvent extends PhotoReadingEvent {}
