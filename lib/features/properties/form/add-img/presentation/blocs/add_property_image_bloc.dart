// lib/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/add_property_images.dart';
import 'add_property_image_event.dart';
import 'add_property_image_state.dart';

class AddPropertyImageBloc
    extends Bloc<AddPropertyImageEvent, AddPropertyImageState> {
  final AddPropertyImagesUseCase addPropertyImages;
  final ImagePicker picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  AddPropertyImageBloc(this.addPropertyImages)
    : super(AddPropertyImageInitial()) {
    on<PickImagesEvent>(_onPickImages);
    on<RemoveImageEvent>(_onRemoveImage);
    on<UploadAllImagesEvent>(_onUploadAll);
  }

  Future<void> _onPickImages(PickImagesEvent event, Emitter emit) async {
    final XFile? file = await picker.pickImage(
      source: event.source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file != null) {
      _selectedImages.add(file);
      emit(AddPropertyImagePicked(_selectedImages.map((e) => e.path).toList()));
    }
  }

  void _onRemoveImage(RemoveImageEvent event, Emitter emit) {
    if (event.index >= 0 && event.index < _selectedImages.length) {
      _selectedImages.removeAt(event.index);
      emit(AddPropertyImagePicked(_selectedImages.map((e) => e.path).toList()));
    }
  }

  Future<void> _onUploadAll(UploadAllImagesEvent event, Emitter emit) async {
    if (_selectedImages.isEmpty) return;

    emit(AddPropertyImageLoading());

    final result = await addPropertyImages(
      connectionId: event.connectionId,
      images: _selectedImages,
      description: event.description,
    );

    result.fold(
      (exception) => emit(AddPropertyImageError(exception.toString())),
      (uploaded) {
        _selectedImages.clear();
        emit(AddPropertyImageSuccess(uploaded));
      },
    );
  }
}
