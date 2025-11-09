// lib/features/properties/form/add-img/domain/usecases/add_property_images.dart
import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/photo_connection.dart';
import '../entities/photo_connection_params.dart';
import '../repositories/property_image_repository.dart';

class AddPropertyImagesUseCase {
  final PropertyImageRepository repository;

  AddPropertyImagesUseCase(this.repository);

  Future<Either<Exception, List<PhotoConnection>>> call({
    required String connectionId,
    required List<XFile> images,
    String? description,
  }) {
    return repository.addPropertyImages(
      params: PhotoConnectionParams(
        connectionId: connectionId,
        images: images,
        description: description,
      ),
    );
  }
}
