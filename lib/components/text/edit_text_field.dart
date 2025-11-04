import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData leftIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;

  const EditTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.leftIcon,
    this.hintText,
    this.keyboardType,
    this.maxLines,
    this.validator,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const iconPaddingLeft = 8.0;
    final iconSize = ResponsiveUtils.iconExtraSmall(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: (textStyle ?? ResponsiveUtils.bodySmall(context)).copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        ResponsiveUtils.vSpace(context, 0.0035),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines ?? 1,
              validator: validator,
              decoration: InputDecoration(
                hintText: hintText,
                // Asegura espacio a la izquierda para el icono
                contentPadding: EdgeInsets.only(
                  left:
                      iconSize +
                      iconPaddingLeft +
                      4, // Espacio para el icono + padding + margen extra
                  right: 10,
                  top: 4,
                  bottom: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
              ),
              style: textStyle ?? ResponsiveUtils.bodyMedium(context),
            ),
            Padding(
              padding: const EdgeInsets.only(left: iconPaddingLeft),
              child: Icon(
                leftIcon,
                size: iconSize,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
