// lib/features/properties/form/add-img/domain/repositories/property_image_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/photo_connection.dart';
import '../entities/photo_connection_params.dart';

abstract class PropertyImageRepository {
  Future<Either<Exception, List<PhotoConnection>>> addPropertyImages({
    required PhotoConnectionParams params,
  });
}
