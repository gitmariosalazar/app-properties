// lib/features/properties/form/add-img/presentation/blocs/add_property_image_event.dart
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddPropertyImageEvent extends Equatable {
  const AddPropertyImageEvent();
}

class PickImagesEvent extends AddPropertyImageEvent {
  final String connectionId;
  final String? description;
  final ImageSource source;
  final List<String> imagePaths;

  const PickImagesEvent(
    this.connectionId,
    this.description, {
    this.source = ImageSource.camera,
    this.imagePaths = const [],
  });

  @override
  List<Object?> get props => [connectionId, description, source, imagePaths];
}

class RemoveImageEvent extends AddPropertyImageEvent {
  final int index;
  const RemoveImageEvent(this.index);
  @override
  List<Object> get props => [index];
}

class UploadAllImagesEvent extends AddPropertyImageEvent {
  final String connectionId;
  final String? description;
  const UploadAllImagesEvent(this.connectionId, this.description);
  @override
  List<Object?> get props => [connectionId, description];
}
