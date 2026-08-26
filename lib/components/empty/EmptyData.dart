import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool showButton;
  final double iconSize;
  final Widget? customAction;

  const EmptyState({
    super.key,
    this.title = 'No hay datos',
    this.description,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.buttonText = 'Agregar',
    this.onButtonPressed,
    this.showButton = true,
    this.iconSize = 72,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono
            Icon(icon, size: iconSize, color: iconColor ?? cs.outline),
            const SizedBox(height: 5),

            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),

            // Descripción
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),

            const SizedBox(height: 5),

            // Acción principal
            if (showButton && onButtonPressed != null)
              FilledButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(buttonText!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else if (customAction != null)
              customAction!,

            // Espacio extra por si hay más contenido abajo
          ],
        ),
      ),
    );
  }
}
