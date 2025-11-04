import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final bool circular;
  final Color? color;
  final Color? foregroundColor;
  final double? iconSize;
  final bool loading;
  final bool disabled;
  final String? tooltip;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.onPressed,
    this.circular = false,
    this.color,
    this.foregroundColor,
    this.iconSize,
    this.loading = false,
    this.disabled = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // === COLORES DINÁMICOS ===
    final effectiveColor = disabled
        ? theme.disabledColor
        : color ?? theme.colorScheme.primary;

    final effectiveFgColor = disabled
        ? theme.disabledColor
        : foregroundColor ?? theme.colorScheme.onPrimary;

    // CORREGIDO: Usa context directamente (extensión)
    final effectiveIconSize = iconSize ?? context.iconMedium;

    final isEnabled = !disabled && !loading;

    Widget button;

    if (circular) {
      button = _buildCircularButton(
        context: context,
        color: effectiveColor,
        fgColor: effectiveFgColor,
        iconSize: effectiveIconSize,
        isEnabled: isEnabled,
      );
    } else {
      button = _buildRectangularButton(
        context: context,
        color: effectiveColor,
        fgColor: effectiveFgColor,
        iconSize: effectiveIconSize,
        isEnabled: isEnabled,
        label: label,
      );
    }

    Widget child = loading
        ? _buildLoadingState(
            effectiveColor,
            effectiveFgColor,
            effectiveIconSize,
          )
        : button;

    if (tooltip != null && isEnabled) {
      child = Tooltip(message: tooltip, child: child);
    }

    return Opacity(opacity: disabled ? 0.6 : 1.0, child: child);
  }

  // === BOTÓN CIRCULAR ===
  Widget _buildCircularButton({
    required BuildContext context,
    required Color color,
    required Color fgColor,
    required double iconSize,
    required bool isEnabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(iconSize),
        splashColor: fgColor.withOpacity(0.2),
        highlightColor: fgColor.withOpacity(0.1),
        onTap: isEnabled ? onPressed : null,
        child: Container(
          width: iconSize * 2.2,
          height: iconSize * 2.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: iconSize, color: fgColor),
        ),
      ),
    );
  }

  // === BOTÓN RECTANGULAR ===
  Widget _buildRectangularButton({
    required BuildContext context,
    required Color color,
    required Color fgColor,
    required double iconSize,
    required bool isEnabled,
    required String? label,
  }) {
    final hasLabel = label != null && label.isNotEmpty;

    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon, size: iconSize),
      label: hasLabel
          ? Text(
              label,
              style: context.buttonText.copyWith(
                // CORREGIDO
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
            )
          : const SizedBox.shrink(),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: fgColor,
        disabledBackgroundColor: color.withOpacity(0.3),
        disabledForegroundColor: fgColor.withOpacity(0.5),
        elevation: 3,
        shadowColor: color.withOpacity(0.4),
        padding: EdgeInsets.symmetric(
          horizontal: hasLabel
              ? context.mediumSpacing
              : context.smallSpacing, // CORREGIDO
          vertical: context.smallSpacing * 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.buttonBorderRadiusValue,
          ), // CORREGIDO
        ),
        minimumSize: hasLabel ? const Size(64, 48) : Size(iconSize * 2.2, 48),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // === ESTADO DE CARGA ===
  Widget _buildLoadingState(Color color, Color fgColor, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(fgColor),
        ),
      ),
    );
  }
}
