// lib/components/common/custom_snack_bar.dart
import 'package:flutter/material.dart';
import 'package:app_properties/core/theme/app_colors.dart';

/// Tipos de SnackBar con íconos y colores predefinidos
enum SnackBarType { success, error, warning, info }

/// Clase estática para mostrar SnackBars reutilizables en toda la app
class CustomSnackBar {
  /// Muestra un SnackBar simple con ícono y color según tipo
  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 2),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    hideCurrent(context);

    _showSnackBar(
      context: context,
      message: message,
      type: type,
      duration: duration,
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );
  }

  /// Muestra un SnackBar con botón de acción (ej: Reintentar)
  /// Muestra un SnackBar con botón de acción (opcional)
  static void showWithAction({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    required String actionLabel,
    required VoidCallback onActionPressed, // ← AÚN REQUIRED
    Duration duration = const Duration(seconds: 5),
  }) {
    hideCurrent(context);
    _showSnackBar(
      context: context,
      message: message,
      type: type,
      duration: duration,
      action: SnackBarAction(
        label: actionLabel,
        textColor: Colors.white,
        onPressed: onActionPressed,
      ),
    );
  }

  /// Muestra un SnackBar de carga con spinner
  static void showLoading({
    required BuildContext context,
    String message = 'Guardando...',
    Duration? autoHideAfter,
  }) {
    hideCurrent(context); // ← CORREGIDO
    final snackBar = SnackBar(
      content: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: autoHideAfter ?? const Duration(minutes: 5),
      margin: _safeMargin(context),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Oculta el SnackBar actual
  static void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Limpia todos los SnackBars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // === MÉTODOS PRIVADOS ===

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    required Duration duration,
    SnackBarAction? action,
  }) {
    final icon = _getIcon(type);
    final color = _getColor(type, context);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
      margin: _safeMargin(context),
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackBarType type) {
    return switch (type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning_amber,
      SnackBarType.info => Icons.info,
    };
  }

  static Color _getColor(SnackBarType type, BuildContext context) {
    return switch (type) {
      SnackBarType.success => AppColors.secondary,
      SnackBarType.error => AppColors.error,
      SnackBarType.warning => Colors.orange[700]!,
      SnackBarType.info => Theme.of(context).primaryColor,
    };
  }

  /// Margen seguro para notch y bordes
  static EdgeInsets _safeMargin(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      bottom: 16,
      left: 16,
      right: 16,
      top: padding.top + 16,
    );
  }
}
