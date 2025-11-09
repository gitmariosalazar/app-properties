// lib/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/usecases/add_property_images.dart';
import 'add_property_image_event.dart';
import 'add_property_image_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

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
    on<PickImageFromCameraEvent>(
      _onPickImageFromCamera,
      transformer: droppable(),
    );
  }

  Future<void> _onPickImageFromCamera(
    PickImageFromCameraEvent event,
    Emitter emit,
  ) async {
    emit(AddPropertyImageLoading()); // Activa loading inmediatamente

    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false, // Evita HEIC en iOS
      );

      if (file == null) {
        // Usuario canceló → volvemos al estado anterior sin error
        if (state is AddPropertyImagePicked) {
          emit(
            AddPropertyImagePicked(
              (state as AddPropertyImagePicked).imagePaths,
            ),
          );
        } else {
          emit(AddPropertyImageInitial());
        }
        return;
      }

      final String path = file.path.toLowerCase();
      final bool isValid =
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');

      if (!isValid) {
        emit(
          AddPropertyImageError(
            'Solo se permiten imágenes en formato JPG o PNG',
          ),
        );
        return;
      }

      // Agregar a la lista
      _selectedImages.add(file);

      // Emitir estado con rutas
      emit(AddPropertyImagePicked(_selectedImages.map((e) => e.path).toList()));
    } catch (e) {
      emit(AddPropertyImageError('Error al tomar la foto: ${e.toString()}'));
    }
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
