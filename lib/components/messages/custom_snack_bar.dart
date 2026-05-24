// lib/components/messages/custom_snack_bar.dart
import 'package:flutter/material.dart';

/// Tipos de SnackBar con íconos y colores predefinidos
enum SnackBarType { success, error, warning, info }

/// Static helper for themed SnackBar notifications.
/// Colors resolved from [ColorScheme] — adapts to light/dark.
class CustomSnackBar {
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

  static void showWithAction({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    required String actionLabel,
    required VoidCallback onActionPressed,
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

  static void showLoading({
    required BuildContext context,
    String message = 'Guardando...',
    Duration? autoHideAfter,
  }) {
    hideCurrent(context);
    final cs = Theme.of(context).colorScheme;
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
      backgroundColor: cs.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: autoHideAfter ?? const Duration(minutes: 5),
      margin: _safeMargin(context),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void hideCurrent(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

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
    final cs = Theme.of(context).colorScheme;
    return switch (type) {
      SnackBarType.success => cs.secondary,
      SnackBarType.error => cs.error,
      SnackBarType.warning => const Color(0xFFE65100), // deep orange — visible in both modes
      SnackBarType.info => cs.primary,
    };
  }

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
