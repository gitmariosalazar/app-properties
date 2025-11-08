// lib/features/properties/presentation/widgets/connection/images_section.dart
import 'dart:io';
import 'package:app_properties/components/common/form_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ImagesSection extends StatelessWidget {
  final List<XFile> selectedImages;

  const ImagesSection({super.key, required this.selectedImages});

  @override
  Widget build(BuildContext context) {
    final double imageSize = context.isTablet ? 90.0 : 55.0;

    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ],
          ),
          context.vSpace(0.01),
          SizedBox(
            height: imageSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length + 1,
              separatorBuilder: (_, __) =>
                  SizedBox(width: context.smallSpacing),
              itemBuilder: (context, index) {
                if (index == selectedImages.length) {
                  return _buildAddImageButton(imageSize, context);
                } else {
                  final file = File(selectedImages[index].path);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          file,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.error.withOpacity(0.3),
                              child: Center(
                                child: Text(
                                  'Error',
                                  style: context.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            selectedImages.removeAt(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(double size, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedImage != null) {
          selectedImages.add(pickedImage);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface.withOpacity(0.75),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.45),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add_a_photo_rounded,
          size: size * 0.48,
          color: AppColors.primary.withOpacity(0.82),
        ),
      ),
    );
  }
}
