// lib/features/properties/form/add-img/presentation/blocs/add_property_image_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/photo_connection.dart';

abstract class AddPropertyImageState extends Equatable {
  const AddPropertyImageState();
}

class AddPropertyImageInitial extends AddPropertyImageState {
  @override
  List<Object> get props => [];
}

class AddPropertyImageLoading extends AddPropertyImageState {
  @override
  List<Object> get props => [];
}

class AddPropertyImagePicked extends AddPropertyImageState {
  final List<String> imagePaths;
  const AddPropertyImagePicked(this.imagePaths);
  @override
  List<Object> get props => [imagePaths];
}

class AddPropertyImageSuccess extends AddPropertyImageState {
  final List<PhotoConnection> images;
  const AddPropertyImageSuccess(this.images);
  @override
  List<Object> get props => [images];
}

class AddPropertyImageError extends AddPropertyImageState {
  final String message;
  const AddPropertyImageError(this.message);
  @override
  List<Object> get props => [message];
}
