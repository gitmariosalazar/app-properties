import 'package:flutter/material.dart';

/// Style variants of the badge, defining background saturation, borders, and text styles.
enum BadgeVariant {
  /// Saturated, solid background with high-contrast text and icons (Heavy/Filled).
  heavy,

  /// Soft, tinted background with vibrant text, icons, and matching subtle borders (Medium/Tinted).
  medium,

  /// Ultra-light/transparent background with fine matching borders and vibrant text (Light/Outlined).
  light,
}

/// Color themes tailored for specific meanings, mimicking professional design systems.
enum BadgeColorTheme {
  /// Informational or default state (Blue).
  info,

  /// Successful action or completed state (Green).
  success,

  /// Warning or pending state (Gold/Yellow).
  warning,

  /// Error, high-priority or dangerous state (Red).
  danger,

  /// Neutral, disabled or default state (Grey).
  neutral,

  /// Custom theme enabling developer to pass custom colors.
  custom,
}

/// Dynamic sizing options for flexible integration across UI contexts.
enum BadgeSize {
  small,
  medium,
  large,
}

class CustomBadge extends StatelessWidget {
  /// The text displayed inside the badge.
  final String label;

  /// The style variant defining opacity and borders.
  final BadgeVariant variant;

  /// The predefined color theme.
  final BadgeColorTheme theme;

  /// The badge sizing preset.
  final BadgeSize size;

  /// Whether to display the icon.
  final bool showIcon;

  /// Custom icon data to override the default theme icon.
  final IconData? icon;

  /// Custom background color override (only active if [theme] is [BadgeColorTheme.custom]).
  final Color? customBgColor;

  /// Custom text color override (only active if [theme] is [BadgeColorTheme.custom]).
  final Color? customTextColor;

  /// Custom border color override (only active if [theme] is [BadgeColorTheme.custom]).
  final Color? customBorderColor;

  /// Custom icon color override (only active if [theme] is [BadgeColorTheme.custom]).
  final Color? customIconColor;

  const CustomBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.medium,
    this.theme = BadgeColorTheme.neutral,
    this.size = BadgeSize.medium,
    this.showIcon = true,
    this.icon,
    this.customBgColor,
    this.customTextColor,
    this.customBorderColor,
    this.customIconColor,
  });

  /// Helper to get default icon for each theme.
  IconData _getDefaultIcon() {
    switch (theme) {
      case BadgeColorTheme.info:
        return Icons.info_outline_rounded;
      case BadgeColorTheme.success:
        return Icons.check_circle_outline_rounded;
      case BadgeColorTheme.warning:
        return Icons.warning_amber_rounded;
      case BadgeColorTheme.danger:
        return Icons.error_outline_rounded;
      case BadgeColorTheme.neutral:
      case BadgeColorTheme.custom:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Resolve colors based on theme, variant, and dark/light mode.
    final colors = _resolveColors(isDarkMode);

    // Padding and spacing based on size.
    final padding = _resolvePadding(context);
    final textStyle = _resolveTextStyle(colors.textColor);
    final iconSize = _resolveIconSize();
    final spacing = _resolveSpacing();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: colors.bgColor,
        borderRadius: BorderRadius.circular(100), // Stadium capsule shape
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!, width: 1.0)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? _getDefaultIcon(),
              size: iconSize,
              color: colors.iconColor,
            ),
            SizedBox(width: spacing),
          ],
          Text(
            label,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  /// Curated color palettes matching the requested design layout in Light/Dark mode.
  _BadgeColors _resolveColors(bool isDarkMode) {
    if (theme == BadgeColorTheme.custom) {
      return _BadgeColors(
        bgColor: customBgColor ?? Colors.grey.shade200,
        textColor: customTextColor ?? Colors.grey.shade900,
        borderColor: customBorderColor,
        iconColor: customIconColor ?? customTextColor ?? Colors.grey.shade900,
      );
    }

    switch (variant) {
      case BadgeVariant.heavy:
        return _resolveHeavyColors(isDarkMode);
      case BadgeVariant.medium:
        return _resolveMediumColors(isDarkMode);
      case BadgeVariant.light:
        return _resolveLightColors(isDarkMode);
    }
  }

  _BadgeColors _resolveHeavyColors(bool isDarkMode) {
    switch (theme) {
      case BadgeColorTheme.info:
        return _BadgeColors(
          bgColor: const Color(0xFF0066CC),
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case BadgeColorTheme.success:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF386A0B) : const Color(0xFF4C7D0E),
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case BadgeColorTheme.warning:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF3E2C04) : const Color(0xFF4D3807),
          textColor: const Color(0xFFFBE093),
          borderColor: isDarkMode ? const Color(0xFF6B5111) : const Color(0xFF5C4308),
          iconColor: const Color(0xFFFBE093),
        );
      case BadgeColorTheme.danger:
        return _BadgeColors(
          bgColor: const Color(0xFFC0242D),
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case BadgeColorTheme.neutral:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF4F5154) : const Color(0xFF5F6368),
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case BadgeColorTheme.custom:
        return _BadgeColors(
          bgColor: customBgColor ?? Colors.grey.shade200,
          textColor: customTextColor ?? Colors.grey.shade900,
          borderColor: customBorderColor,
          iconColor: customIconColor ?? customTextColor ?? Colors.grey.shade900,
        );
    }
  }

  _BadgeColors _resolveMediumColors(bool isDarkMode) {
    switch (theme) {
      case BadgeColorTheme.info:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF1B365D) : const Color(0xFFE5F1FF),
          textColor: isDarkMode ? const Color(0xFF80BFFF) : const Color(0xFF0056B3),
          iconColor: isDarkMode ? const Color(0xFF80BFFF) : const Color(0xFF0056B3),
          borderColor: isDarkMode ? const Color(0xFF264C80) : const Color(0xFFB3D9FF),
        );
      case BadgeColorTheme.success:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF1B3D11) : const Color(0xFFF0F9EB),
          textColor: isDarkMode ? const Color(0xFF8CE172) : const Color(0xFF3B6E0C),
          iconColor: isDarkMode ? const Color(0xFF8CE172) : const Color(0xFF3B6E0C),
          borderColor: isDarkMode ? const Color(0xFF2D5C1E) : const Color(0xFFC2E0A4),
        );
      case BadgeColorTheme.warning:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF3A2D0C) : const Color(0xFFFEF8EC),
          textColor: isDarkMode ? const Color(0xFFF5C242) : const Color(0xFF8D6809),
          iconColor: isDarkMode ? const Color(0xFFF5C242) : const Color(0xFF8D6809),
          borderColor: isDarkMode ? const Color(0xFF554417) : const Color(0xFFFBE093),
        );
      case BadgeColorTheme.danger:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF461A1D) : const Color(0xFFFEF0F0),
          textColor: isDarkMode ? const Color(0xFFFF8588) : const Color(0xFF9D1C24),
          iconColor: isDarkMode ? const Color(0xFFFF8588) : const Color(0xFF9D1C24),
          borderColor: isDarkMode ? const Color(0xFF6B262B) : const Color(0xFFF8BDC2),
        );
      case BadgeColorTheme.neutral:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0xFF2E3033) : const Color(0xFFF4F5F7),
          textColor: isDarkMode ? const Color(0xFFC4C7CC) : const Color(0xFF4F5154),
          iconColor: isDarkMode ? const Color(0xFFC4C7CC) : const Color(0xFF4F5154),
          borderColor: isDarkMode ? const Color(0xFF404245) : const Color(0xFFE8EAED),
        );
      case BadgeColorTheme.custom:
        return _BadgeColors(
          bgColor: customBgColor ?? Colors.grey.shade200,
          textColor: customTextColor ?? Colors.grey.shade900,
          borderColor: customBorderColor,
          iconColor: customIconColor ?? customTextColor ?? Colors.grey.shade900,
        );
    }
  }

  _BadgeColors _resolveLightColors(bool isDarkMode) {
    switch (theme) {
      case BadgeColorTheme.info:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0x0C80BFFF) : const Color(0x0C0066CC),
          textColor: isDarkMode ? const Color(0xFF80BFFF) : const Color(0xFF0066CC),
          iconColor: isDarkMode ? const Color(0xFF80BFFF) : const Color(0xFF0066CC),
          borderColor: isDarkMode ? const Color(0xFF264C80) : const Color(0xFFCCE6FF),
        );
      case BadgeColorTheme.success:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0x0C8CE172) : const Color(0x0C4C7D0E),
          textColor: isDarkMode ? const Color(0xFF8CE172) : const Color(0xFF4C7D0E),
          iconColor: isDarkMode ? const Color(0xFF8CE172) : const Color(0xFF4C7D0E),
          borderColor: isDarkMode ? const Color(0xFF2D5C1E) : const Color(0xFFD6ECC2),
        );
      case BadgeColorTheme.warning:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0x0CF5C242) : const Color(0x0C8D6809),
          textColor: isDarkMode ? const Color(0xFFF5C242) : const Color(0xFF8D6809),
          iconColor: isDarkMode ? const Color(0xFFF5C242) : const Color(0xFF8D6809),
          borderColor: isDarkMode ? const Color(0xFF554417) : const Color(0xFFFDF0CD),
        );
      case BadgeColorTheme.danger:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0x0CFF8588) : const Color(0x0CC0242D),
          textColor: isDarkMode ? const Color(0xFFFF8588) : const Color(0xFFC0242D),
          iconColor: isDarkMode ? const Color(0xFFFF8588) : const Color(0xFFC0242D),
          borderColor: isDarkMode ? const Color(0xFF6B262B) : const Color(0xFFFCD3D7),
        );
      case BadgeColorTheme.neutral:
        return _BadgeColors(
          bgColor: isDarkMode ? const Color(0x0CC4C7CC) : const Color(0x0C5F6368),
          textColor: isDarkMode ? const Color(0xFFC4C7CC) : const Color(0xFF5F6368),
          iconColor: isDarkMode ? const Color(0xFFC4C7CC) : const Color(0xFF5F6368),
          borderColor: isDarkMode ? const Color(0xFF404245) : const Color(0xFFE2E4E8),
        );
      case BadgeColorTheme.custom:
        return _BadgeColors(
          bgColor: customBgColor ?? Colors.grey.shade200,
          textColor: customTextColor ?? Colors.grey.shade900,
          borderColor: customBorderColor,
          iconColor: customIconColor ?? customTextColor ?? Colors.grey.shade900,
        );
    }
  }

  EdgeInsets _resolvePadding(BuildContext context) {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 8);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
    }
  }

  double _resolveIconSize() {
    switch (size) {
      case BadgeSize.small:
        return 14.0;
      case BadgeSize.large:
        return 20.0;
      case BadgeSize.medium:
        return 16.0;
    }
  }

  double _resolveSpacing() {
    switch (size) {
      case BadgeSize.small:
        return 4.0;
      case BadgeSize.large:
        return 8.0;
      case BadgeSize.medium:
        return 6.0;
    }
  }

  TextStyle _resolveTextStyle(Color textColor) {
    double fontSize;
    switch (size) {
      case BadgeSize.small:
        fontSize = 11.0;
        break;
      case BadgeSize.large:
        fontSize = 14.0;
        break;
      case BadgeSize.medium:
        fontSize = 12.0;
        break;
    }

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.25,
      height: 1.1,
    );
  }
}

class _BadgeColors {
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final Color iconColor;

  const _BadgeColors({
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.iconColor,
  });
}
