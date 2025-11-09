// lib/features/properties/form/add-img/domain/entities/photo_connection_params.dart
import 'package:image_picker/image_picker.dart';

class PhotoConnectionParams {
  final String connectionId;
  final List<XFile> images;
  final String? description;

  PhotoConnectionParams({
    required this.connectionId,
    required this.images,
    this.description,
  });
}
