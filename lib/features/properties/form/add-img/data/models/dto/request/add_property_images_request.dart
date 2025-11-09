import 'dart:io';

class AddPropertyImagesRequest {
  final String connectionId;
  final List<File> images; // Multipart
  final String? description;

  AddPropertyImagesRequest({
    required this.connectionId,
    required this.images,
    this.description,
  });
}
