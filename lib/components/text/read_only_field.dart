import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData leftIcon;
  final TextStyle? textStyle;

  const ReadOnlyField({
    super.key,
    required this.controller,
    required this.label,
    required this.leftIcon,
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
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                // Asegura espacio a la izquierda para el icono
                contentPadding: EdgeInsets.only(
                  left:
                      iconSize +
                      iconPaddingLeft +
                      4, // Espacio para el icono + padding + margen extra
                  right: 10,
                  top: 6,
                  bottom: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.extraSmallBorderRadiusValue(context),
                  ),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface.withOpacity(0.6),
              ),
              style: textStyle ?? ResponsiveUtils.bodyMedium(context),
            ),
            // Icono pegado al borde izquierdo
            Positioned(
              left: iconPaddingLeft,
              child: Icon(
                leftIcon,
                size: iconSize,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
