// lib/features/properties/form/add-img/presentation/widgets/images_section.dart
import 'dart:io';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_event.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_state.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ImagesSection extends StatelessWidget {
  final String connectionId;
  final String description;

  const ImagesSection({
    super.key,
    required this.connectionId,
    this.description = 'Imágenes de la acometida',
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize = context.isTablet ? 90.0 : 55.0;

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library,
                color: AppColors.primary,
                size: context.iconSmall,
              ),
              context.hSpace(0.01),
              Text(
                'Fotos de Referencia',
                style: context.titleExtraSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          context.vSpace(0.01),
          SizedBox(
            height: imageSize,
            child: BlocBuilder<AddPropertyImageBloc, AddPropertyImageState>(
              builder: (context, state) {
                final imagePaths = (state is AddPropertyImagePicked)
                    ? state.imagePaths
                    : <String>[];
                final isLoading = state is AddPropertyImageLoading;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagePaths.length + 1,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: context.smallSpacing),
                  itemBuilder: (context, index) {
                    if (index == imagePaths.length) {
                      return _buildAddButton(imageSize, context, isLoading);
                    }

                    final path = imagePaths[index];
                    final file = File(path);

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  width: imageSize,
                                  height: imageSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: imageSize,
                                      height: imageSize,
                                      color: AppColors.surface,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: imageSize,
                                  height: imageSize,
                                  color: AppColors.surface,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => context
                                .read<AddPropertyImageBloc>()
                                .add(RemoveImageEvent(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          BlocListener<AddPropertyImageBloc, AddPropertyImageState>(
            listener: (context, state) {
              if (state is AddPropertyImageSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fotos subidas correctamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (state is AddPropertyImageError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(double size, BuildContext context, bool isLoading) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              // VALIDAR PERMISOS Y TOMAR FOTO
              await _pickAndAddImage(context);
            },
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surface.withOpacity(0.75),
            border: Border.all(
              color: AppColors.primary.withOpacity(isLoading ? 0.2 : 0.45),
              width: 2,
            ),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.add_a_photo_rounded,
                    size: size * 0.48,
                    color: AppColors.primary,
                  ),
          ),
        ),
      ),
    );
  }

  /// TOMA FOTO + VALIDA EXTENSIÓN + AGREGA AL BLoC
  Future<void> _pickAndAddImage(BuildContext context) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false, // Evita HEIC en iOS
      );

      if (image == null) return;

      final String path = image.path.toLowerCase();
      final bool isValid =
          path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');

      if (!isValid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solo se permiten imágenes en formato JPG o PNG'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // AGREGAR AL BLoC
      context.read<AddPropertyImageBloc>().add(
        PickImagesEvent(connectionId, description, imagePaths: [image.path]),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar la foto: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
