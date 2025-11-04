// lib/features/form/data/repositories/photo_reading_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/form/domain/entities/photo_reading_entity.dart';
import 'package:app_properties/features/form/domain/repositories/photo_reading_repository.dart';
import 'package:app_properties/features/form/data/datasources/photo_reading_datasource.dart';
import 'dart:io';

class PhotoReadingRepositoryImpl implements PhotoReadingRepository {
  final PhotoReadingDataSource dataSource;

  PhotoReadingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<PhotoReadingEntity>>> createPhotoReadings({
    required List<File> images,
    required int readingId,
    required String cadastralKey,
    String? description,
  }) async {
    try {
      final result = await dataSource.createPhotoReadings(
        images: images,
        readingId: readingId,
        cadastralKey: cadastralKey,
        description: description,
      );
      return result.fold(
        (failure) => Left(failure),
        (models) => Right(models.map((model) => model.toEntity()).toList()),
      );
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
