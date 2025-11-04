// lib/features/form/domain/usecases/create_photo_reading_use_case.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/form/domain/entities/photo_reading_entity.dart';
import 'package:app_properties/features/form/domain/repositories/photo_reading_repository.dart';

class CreatePhotoReadingUseCase
    implements UseCase<List<PhotoReadingEntity>, CreatePhotoReadingParams> {
  final PhotoReadingRepository repository;

  CreatePhotoReadingUseCase(this.repository);

  @override
  Future<Either<Failure, List<PhotoReadingEntity>>> call(
    CreatePhotoReadingParams params,
  ) async {
    if (params.images.isEmpty) {
      return Left(ServerFailure());
    }
    return await repository.createPhotoReadings(
      images: params.images,
      readingId: params.readingId,
      cadastralKey: params.cadastralKey,
      description: params.description,
    );
  }
}

class CreatePhotoReadingParams {
  final List<File> images;
  final int readingId;
  final String cadastralKey;
  final String? description;

  CreatePhotoReadingParams({
    required this.images,
    required this.readingId,
    required this.cadastralKey,
    this.description,
  });
}
