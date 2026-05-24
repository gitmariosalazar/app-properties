import 'package:flutter/material.dart';

class ConsumptionUtils {
  static String calculateConsumption(String current, String previous) {
    final double? currentVal = double.tryParse(current);
    final double? previousVal = double.tryParse(previous);
    if (currentVal == null || previousVal == null) return '0.00';
    final double result = (currentVal - previousVal);
    return result.toStringAsFixed(2);
  }

  /// Returns visuals that work in both light and dark mode.
  /// Uses explicit hex colors with sufficient contrast in both themes.
  static ConsumptionVisuals setConsumptionVisuals({
    required double? currentConsumption,
    required double? averageConsumption,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    // Neutral (default)
    Color bgColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF5F5F5);
    Color textColor = isDark
        ? const Color(0xFFBBBBBB)
        : const Color(0xFF616161);
    IconData icon = Icons.info_outline;

    if (currentConsumption == null ||
        averageConsumption == null ||
        averageConsumption == 0) {
      return ConsumptionVisuals(
        backgroundColor: bgColor,
        textColor: textColor,
        icon: icon,
      );
    }

    final double lowerGreen = averageConsumption * 0.6;
    final double upperGreen = averageConsumption * 1.4;
    final double lowerWarning = averageConsumption * 0.3;
    final double upperWarning = averageConsumption * 1.7;

    if (currentConsumption >= lowerGreen && currentConsumption <= upperGreen) {
      // ✅ Normal: ±40% del promedio
      bgColor = isDark
          ? const Color(0xFF1B3A1B)
          : const Color(0xFFE8F5E9);
      textColor = isDark
          ? const Color(0xFF81C784)
          : const Color(0xFF1B5E20);
      icon = Icons.check_circle_outline;
    } else if ((currentConsumption >= lowerWarning &&
            currentConsumption < lowerGreen) ||
        (currentConsumption > upperGreen &&
            currentConsumption <= upperWarning)) {
      // 🟠 Warning: ±40%–70%
      bgColor = isDark
          ? const Color(0xFF3E2700)
          : const Color(0xFFFFF3E0);
      textColor = isDark
          ? const Color(0xFFFFB74D)
          : const Color(0xFFE65100);
      icon = Icons.warning_amber_rounded;
    } else {
      // 🔴 Critical: >±70%
      bgColor = isDark
          ? const Color(0xFF3B0A0A)
          : const Color(0xFFFFEBEE);
      textColor = isDark
          ? const Color(0xFFEF9A9A)
          : const Color(0xFFB71C1C);
      icon = Icons.error_outline;
    }

    return ConsumptionVisuals(
      backgroundColor: bgColor,
      textColor: textColor,
      icon: icon,
    );
  }
}

class ConsumptionVisuals {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  ConsumptionVisuals({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}
