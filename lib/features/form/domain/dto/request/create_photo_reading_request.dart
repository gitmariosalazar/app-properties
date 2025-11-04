// lib/features/form/domain/dto/request/create_photo_reading_request.dart
import 'dart:io';

class CreatePhotoReadingRequest {
  final int readingId;
  final List<File> images;
  final String cadastralKey;
  final String? description;

  CreatePhotoReadingRequest({
    required this.readingId,
    required this.images,
    required this.cadastralKey,
    this.description,
  });
}
