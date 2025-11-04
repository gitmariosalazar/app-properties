// lib/features/form/domain/repositories/photo_reading_repository.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/form/domain/entities/photo_reading_entity.dart';
import 'dart:io';

abstract class PhotoReadingRepository {
  Future<Either<Failure, List<PhotoReadingEntity>>> createPhotoReadings({
    required List<File> images,
    required int readingId,
    required String cadastralKey,
    String? description,
  });
}
