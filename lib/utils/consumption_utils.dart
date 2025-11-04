import 'package:flutter/material.dart';

class ConsumptionUtils {
  static String calculateConsumption(String current, String previous) {
    final double? currentVal = double.tryParse(current);
    final double? previousVal = double.tryParse(previous);
    if (currentVal == null || previousVal == null) return '0.00';
    final double result = (currentVal - previousVal);
    return result.toStringAsFixed(2);
  }

  static ConsumptionVisuals setConsumptionVisuals({
    required double? currentConsumption,
    required double? averageConsumption,
  }) {
    // Valores por defecto = neutral (gris)
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.black87;
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

    final double lowerGreen = averageConsumption * 0.6; // -40%
    final double upperGreen = averageConsumption * 1.4; // +40%
    final double lowerWarning = averageConsumption * 0.3; // -70%
    final double upperWarning = averageConsumption * 1.7; // +70%

    if (currentConsumption >= lowerGreen && currentConsumption <= upperGreen) {
      // ✅ Verde: ±40% del promedio
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
      icon = Icons.check_circle_outline;
    } else if ((currentConsumption >= lowerWarning &&
            currentConsumption < lowerGreen) ||
        (currentConsumption > upperGreen &&
            currentConsumption <= upperWarning)) {
      // 🟠 Naranja: -30% a -70% o +40% a +70%
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
      icon = Icons.warning_amber_rounded;
    } else {
      // 🔴 Rojo: <-70% o >+70%
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade900;
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
