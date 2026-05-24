import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class DialogUtils {
  /// Animated result dialog (success, error, etc.).
  /// Dialog background from [ColorScheme] — adapts to light/dark.
  static void showResultDialog(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    final cs = Theme.of(context).colorScheme;
    final radius = context.largeBorderRadiusValue;
    final iconSize = context.iconLarge;
    final fontSize = context.titleMedium.fontSize ?? 20;
    final sidePad = context.mediumSpacing * 1.7;
    final verticalPad = context.mediumSpacing * 1.3;

    showGeneralDialog(
      context: context,
      barrierLabel: "Resultado",
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              backgroundColor: cs.surfaceContainerHighest,
              elevation: 12,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePad,
                  vertical: verticalPad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.11),
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(iconSize * 0.21),
                            child: Icon(icon, size: iconSize, color: color),
                          ),
                        );
                      },
                    ),
                    context.vSpace(0.018),
                    Text(
                      message,
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: color,
                        letterSpacing: 0.1,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    context.vSpace(0.018),
                    SizedBox(
                      width: double.infinity,
                      child: _AnimatedActionButton(
                        label: 'Cerrar',
                        icon: Icons.close,
                        color: color,
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.microtask(() {
                            if (context.mounted) {
                              context.go('/home');
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Animated confirmation dialog.
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
    required List<Map<String, String>> fields,
  }) {
    final cs = Theme.of(context).colorScheme;
    final radius = context.largeBorderRadiusValue;
    final sidePad = context.mediumSpacing * 1.2;
    final verticalPad = context.mediumSpacing * 1.1;

    return showGeneralDialog<bool>(
      context: context,
      barrierLabel: "Confirmar",
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, _, _) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              backgroundColor: cs.surfaceContainerHighest,
              elevation: 16,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sidePad,
                  vertical: verticalPad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: cs.primary,
                          size: 22,
                        ),
                        context.hSpace(0.03),
                        Text(
                          'Confirmar Guardado',
                          style: context.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    context.vSpace(0.017),
                    Text(
                      'Por favor, revise los datos antes de guardar:',
                      style: context.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    context.vSpace(0.013),
                    ...fields.map(
                      (field) => _confirmationField(
                        context,
                        field['label']!,
                        field['value']!,
                        cs,
                      ),
                    ),
                    context.vSpace(0.025),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _AnimatedActionButton(
                          label: 'Cancelar',
                          icon: Icons.cancel,
                          color: cs.error,
                          isOutlined: true,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        context.hSpace(0.06),
                        _AnimatedActionButton(
                          label: 'Guardar',
                          icon: Icons.save,
                          color: cs.primary,
                          onPressed: () {
                            onConfirm();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _confirmationField(
    BuildContext context,
    String label,
    String value,
    ColorScheme cs,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.smallSpacing * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: cs.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// === BOTÓN ANIMADO REUTILIZABLE (interno) ===
class _AnimatedActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isOutlined;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isOutlined = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.largeBorderRadiusValue * 0.55;
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.mediumSpacing,
              vertical: context.smallSpacing * 1.2,
            ),
          )
        : FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.mediumSpacing * 1.2,
              vertical: context.smallSpacing * 1.4,
            ),
            elevation: 2,
            shadowColor: color.withValues(alpha: 0.3),
          );

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Semantics(
        button: true,
        label: label,
        child: isOutlined
            ? OutlinedButton.icon(
                style: buttonStyle,
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: Text(
                  label,
                  style: context.buttonText.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : FilledButton.icon(
                style: buttonStyle,
                onPressed: onPressed,
                icon: Icon(icon, size: 20),
                label: Text(
                  label,
                  style: context.buttonText.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
