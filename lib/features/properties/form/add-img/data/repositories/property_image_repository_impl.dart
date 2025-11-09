// lib/features/properties/form/add-img/data/repositories/property_image_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/photo_connection.dart';
import '../../domain/entities/photo_connection_params.dart';
import '../../domain/repositories/property_image_repository.dart';
import '../datasources/property_image_remote_data_source.dart';

class PropertyImageRepositoryImpl implements PropertyImageRepository {
  final PropertyImageRemoteDataSource remoteDataSource;

  PropertyImageRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Exception, List<PhotoConnection>>> addPropertyImages({
    required PhotoConnectionParams params,
  }) async {
    try {
      final result = await remoteDataSource.addPropertyImages(
        connectionId: params.connectionId,
        images: params.images,
        description: params.description,
      );
      return result.fold(
        (failure) => Left(Exception(failure.toString())),
        (data) => Right(data),
      );
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
