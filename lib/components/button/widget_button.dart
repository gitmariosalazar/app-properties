import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

enum ActionButtonStyle { elevated, outlined, text }

enum ActionButtonSize { small, medium, large }

class ActionButton extends StatelessWidget {
  // === Contenido ===
  final IconData icon;
  final String? label;
  final String? tooltip;
  final String? semanticLabel;

  // === Estado ===
  final VoidCallback? onPressed;
  final bool disabled;
  final bool loading;

  // === Apariencia ===
  final bool circular;
  final Color? color;
  final ActionButtonStyle style;
  final ActionButtonSize size;

  // === Extras ===
  final Widget? trailing; // Para badges, counters, etc.
  final double? iconSizeOverride;
  final bool hideButton;
  final bool hideElevation;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    this.tooltip,
    this.semanticLabel,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.circular = false,
    this.color,
    this.style = ActionButtonStyle.elevated,
    this.size = ActionButtonSize.medium,
    this.trailing,
    this.iconSizeOverride,
    this.hideButton = false,
    this.hideElevation = false,
  });

  // === Helpers internos ===
  bool get _isDisabled => disabled || onPressed == null || loading;
  bool get _hasLabel => label != null && label!.isNotEmpty;

  double _getIconSize(BuildContext context) {
    if (iconSizeOverride != null) return iconSizeOverride!;
    return switch (size) {
      ActionButtonSize.small => ResponsiveUtils.iconSmall(context),
      ActionButtonSize.medium => ResponsiveUtils.iconMedium(context),
      ActionButtonSize.large => ResponsiveUtils.iconLarge(context),
    };
  }

  double _getVerticalPadding(BuildContext context) {
    return switch (size) {
      ActionButtonSize.small => ResponsiveUtils.smallSpacing(context),
      ActionButtonSize.medium => ResponsiveUtils.smallSpacing(context) * 1.2,
      ActionButtonSize.large => ResponsiveUtils.mediumSpacing(context),
    };
  }

  double _getHorizontalPadding(BuildContext context) {
    return switch (size) {
      ActionButtonSize.small => ResponsiveUtils.mediumSpacing(context),
      ActionButtonSize.medium => ResponsiveUtils.mediumSpacing(context) * 1.3,
      ActionButtonSize.large => ResponsiveUtils.largeSpacing(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hideButton) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveColor = color ?? colorScheme.primary;
    final iconSize = _getIconSize(context);
    final borderRadius = circular
        ? iconSize
        : ResponsiveUtils.buttonBorderRadius(context);

    final isDisabled = _isDisabled;
    final isLoading = loading && !isDisabled;

    // === Estilos por tipo ===
    Color? fillColor;
    Color? foregroundColor;
    double elevation = hideElevation ? 0 : ResponsiveUtils.cardElevation(context);

    switch (style) {
      case ActionButtonStyle.elevated:
        fillColor = isDisabled ? theme.disabledColor : effectiveColor;
        foregroundColor = Colors.white;
        elevation = isDisabled ? 0 : elevation;
        break;

      case ActionButtonStyle.outlined:
        fillColor = isDisabled ? Colors.transparent : Colors.transparent;
        foregroundColor = isDisabled ? theme.disabledColor : effectiveColor;
        elevation = 0;
        break;

      case ActionButtonStyle.text:
        fillColor = Colors.transparent;
        foregroundColor = isDisabled ? theme.disabledColor : effectiveColor;
        elevation = 0;
        break;
    }

    // === Widget del ícono (con loading) ===
    Widget iconWidget = isLoading
        ? SizedBox(
            width: iconSize * 0.8,
            height: iconSize * 0.8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                style == ActionButtonStyle.elevated
                    ? Colors.white
                    : foregroundColor,
              ),
            ),
          )
        : Icon(icon, size: iconSize, color: foregroundColor);

    // === Botón base ===
    Widget button;

    if (circular) {
      button = RawMaterialButton(
        onPressed: isDisabled ? null : onPressed,
        elevation: elevation,
        fillColor: fillColor,
        shape: CircleBorder(
          side: style == ActionButtonStyle.outlined
              ? BorderSide(color: foregroundColor, width: 1.5)
              : BorderSide.none,
        ),
        constraints: BoxConstraints.tightFor(
          width: iconSize * 2.2,
          height: iconSize * 2.2,
        ),
        child: iconWidget,
      );
    } else {
      // Botón con label
      final labelWidget = _hasLabel
          ? Text(
              label!,
              style: ResponsiveUtils.buttonText(context).copyWith(
                color: foregroundColor,
                fontSize: switch (size) {
                  ActionButtonSize.small => 12,
                  ActionButtonSize.medium => 14,
                  ActionButtonSize.large => 16,
                },
              ),
            )
          : null;

      button = ElevatedButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: iconWidget,
        label: labelWidget ?? const SizedBox.shrink(),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
            vertical: _getVerticalPadding(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: style == ActionButtonStyle.outlined
                ? BorderSide(color: foregroundColor, width: 1.5)
                : BorderSide.none,
          ),
          backgroundColor: fillColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          shadowColor: effectiveColor.withValues(alpha: 0.3),
          disabledBackgroundColor: theme.disabledColor,
          minimumSize: Size(
            size == ActionButtonSize.small ? 80 : 100,
            size == ActionButtonSize.small ? 36 : 44,
          ),
        ),
      );
    }

    // === Trailing (badge, contador, etc.) ===
    if (trailing != null && !circular && _hasLabel) {
      button = Stack(
        children: [
          button,
          Positioned(right: 8, top: 8, child: trailing!),
        ],
      );
    }

    // === Tooltip ===
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // === Accesibilidad semántica ===
    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? label ?? tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: button,
      ),
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final bool enable;
  final double height;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.loading = false,
    this.enable = true,
    required this.height,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enable ? 1.0 : 0.45,
      child: ColorFiltered(
        colorFilter: enable
            ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
            : const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
        child: GestureDetector(
          onTapDown: enable && !loading
              ? (_) => animationController.forward()
              : null,
          onTapUp: enable ? (_) => animationController.reverse() : null,
          onTapCancel: enable ? () => animationController.reverse() : null,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: enable ? scaleAnimation.value : 1.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.buttonBorderRadius(context),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(enable ? 0.2 : 0.0),
                        blurRadius: ResponsiveUtils.isSmallDevice(context)
                            ? 8
                            : 12,
                        offset: Offset(
                          0,
                          ResponsiveUtils.isSmallDevice(context) ? 3 : 5,
                        ),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: enable ? onPressed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.buttonBorderRadius(context),
                        ),
                      ),
                      elevation: 0,
                      padding: ResponsiveUtils.cardPadding(context).copyWith(
                        left: ResponsiveUtils.scaleWidth(context, 0.04),
                        right: ResponsiveUtils.scaleWidth(context, 0.04),
                      ),
                      minimumSize: Size(double.infinity, height),
                    ),
                    child: loading
                        ? SizedBox(
                            width: ResponsiveUtils.iconMedium(context),
                            height: ResponsiveUtils.iconMedium(context),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: ResponsiveUtils.iconSmall(context),
                                color: Colors.white,
                              ),
                              ResponsiveUtils.hSpace(context, 0.03),
                              Text(
                                label,
                                style: ResponsiveUtils.buttonText(context)
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
