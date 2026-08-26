import 'package:flutter/material.dart';
import 'dart:math' as math;

/// The semantic status colors for the chip.
enum ColorChipStatus {
  success,
  warning,
  error,
  info,
  primary,
  secondary,
  accent,
}

/// The size variants for the chip.
enum ColorChipSize { xs, sm, md, lg }

/// The visual style variant of the chip.
enum ColorChipVariant { solid, filled, outline, soft, ghost }

/// Position of the icon relative to the text.
enum ColorChipIconPosition { left, right }

/// A highly customizable, professional chip component that adapts perfectly
/// to Light and Dark themes, matching web-based design system specifications.
class ColorChip extends StatefulWidget {
  /// The main color of the chip. Can be overridden by [status].
  final Color? color;

  /// Semantic status color. If provided, overrides 'color'.
  final ColorChipStatus? status;

  /// The text displayed inside the chip.
  final String label;

  /// Size of the chip.
  final ColorChipSize size;

  /// Visual style variant of the chip.
  final ColorChipVariant variant;

  /// Optional icon widget to display alongside the label.
  final Widget? icon;

  /// Position of the icon (left or right).
  final ColorChipIconPosition iconPosition;

  /// Callback when the chip is tapped. If provided, the chip becomes interactive.
  final VoidCallback? onTap;

  /// If true, adds a dot indicator for status (useful in soft or outline variants).
  final bool withDot;

  /// Optional custom border radius. Defaults to fully rounded (pill shape).
  final BorderRadiusGeometry? borderRadius;

  const ColorChip({
    super.key,
    this.color,
    this.status,
    required this.label,
    this.size = ColorChipSize.md,
    this.variant = ColorChipVariant.solid,
    this.icon,
    this.iconPosition = ColorChipIconPosition.left,
    this.onTap,
    this.withDot = false,
    this.borderRadius,
  });

  @override
  State<ColorChip> createState() => _ColorChipState();
}

class _ColorChipState extends State<ColorChip> {
  bool _isHovered = false;
  bool _isPressed = false;

  /// Calculates if the given color is 'light' based on HSP color model
  /// to determine if black or white text should be used for optimal contrast.
  bool _isLightColor(Color c) {
    if (widget.status == ColorChipStatus.warning) return true;
    final hsp = math.sqrt(
      0.299 * (c.red * c.red) +
      0.587 * (c.green * c.green) +
      0.114 * (c.blue * c.blue)
    );
    return hsp > 170;
  }

  /// Resolves the base color of the chip based on status or provided color.
  Color _getBaseColor(BuildContext context) {
    if (widget.status != null) {
      final theme = Theme.of(context);
      switch (widget.status!) {
        case ColorChipStatus.success:
          return const Color(0xFF10b981); // Emerald 500
        case ColorChipStatus.warning:
          return const Color(0xFFf59e0b); // Amber 500
        case ColorChipStatus.error:
          return const Color(0xFFef4444); // Red 500
        case ColorChipStatus.info:
          return const Color(0xFF3b82f6); // Blue 500
        case ColorChipStatus.primary:
          return theme.colorScheme.primary;
        case ColorChipStatus.secondary:
          return theme.colorScheme.secondary;
        case ColorChipStatus.accent:
          return theme.colorScheme.tertiary;
      }
    }
    return widget.color ?? Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = widget.onTap != null;

    // Evaluate sizes
    double paddingHorizontal;
    double paddingVertical;
    double fontSize;
    double height;
    double iconSize;

    switch (widget.size) {
      case ColorChipSize.xs:
        paddingHorizontal = 6; paddingVertical = 2; fontSize = 11; height = 20; iconSize = 12;
        break;
      case ColorChipSize.sm:
        paddingHorizontal = 8; paddingVertical = 4; fontSize = 12; height = 24; iconSize = 14;
        break;
      case ColorChipSize.md:
        paddingHorizontal = 12; paddingVertical = 6; fontSize = 14; height = 32; iconSize = 16;
        break;
      case ColorChipSize.lg:
        paddingHorizontal = 16; paddingVertical = 8; fontSize = 16; height = 40; iconSize = 18;
        break;
    }

    // Color definitions
    Color bgColor = Colors.transparent;
    Color textColor = Colors.white;
    Color borderColor = Colors.transparent;

    final mixColor = isDark ? Colors.white : Colors.black;
    final textMixRatio = isDark ? 0.15 : 0.60;
    
    // Helper to mix colors for adapting to light/dark themes
    Color mix(Color c1, Color c2, double ratio) {
      return Color.lerp(c1, c2, ratio)!;
    }

    final mixedTextColor = mix(baseColor, mixColor, textMixRatio);

    // Apply variants
    switch (widget.variant) {
      case ColorChipVariant.solid:
      case ColorChipVariant.filled:
        bgColor = baseColor;
        textColor = _isLightColor(baseColor) ? const Color(0xFF0F172A) : Colors.white;
        break;
      case ColorChipVariant.outline:
        bgColor = Colors.transparent;
        textColor = mixedTextColor;
        borderColor = baseColor;
        
        if (isInteractive && (_isHovered || _isPressed)) {
          bgColor = baseColor.withOpacity(0.10);
        }
        break;
      case ColorChipVariant.soft:
        final softBgMix = isDark ? 0.15 : 0.08;
        bgColor = baseColor.withOpacity(softBgMix);
        textColor = mixedTextColor;
        borderColor = baseColor.withOpacity(0.20);
        
        if (isInteractive && (_isHovered || _isPressed)) {
          bgColor = baseColor.withOpacity(0.25);
        }
        break;
      case ColorChipVariant.ghost:
        bgColor = Colors.transparent;
        textColor = mixedTextColor;
        
        if (isInteractive && (_isHovered || _isPressed)) {
          bgColor = baseColor.withOpacity(0.10);
        }
        break;
    }

    // Apply interaction brightness simulation
    if (isInteractive && (_isHovered || _isPressed) && 
        (widget.variant == ColorChipVariant.solid || widget.variant == ColorChipVariant.filled)) {
      if (_isPressed) {
        bgColor = mix(bgColor, Colors.black, 0.1);
      } else {
        bgColor = isDark ? mix(bgColor, Colors.white, 0.1) : mix(bgColor, Colors.black, 0.05);
      }
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.withDot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.variant == ColorChipVariant.solid || widget.variant == ColorChipVariant.filled 
                  ? textColor 
                  : baseColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (widget.icon != null && widget.iconPosition == ColorChipIconPosition.left) ...[
          IconTheme(
            data: IconThemeData(color: textColor, size: iconSize),
            child: widget.icon!,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          widget.label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        if (widget.icon != null && widget.iconPosition == ColorChipIconPosition.right) ...[
          const SizedBox(width: 6),
          IconTheme(
            data: IconThemeData(color: textColor, size: iconSize),
            child: widget.icon!,
          ),
        ],
      ],
    );

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (isInteractive) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (isInteractive) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (isInteractive) setState(() => _isPressed = false);
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal, 
            vertical: paddingVertical
          ),
          transform: isInteractive && _isHovered && !_isPressed 
              ? (Matrix4.identity()..translate(0.0, -1.0)) 
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(9999),
            border: borderColor != Colors.transparent 
                ? Border.all(color: borderColor, width: 1) 
                : null,
          ),
          child: Center(
            widthFactor: 1.0,
            child: content,
          ),
        ),
      ),
    );
  }
}
