import 'package:flutter/material.dart';

class ProfessionalLoader extends StatelessWidget {
  final String label;
  final String description;

  const ProfessionalLoader({
    super.key,
    this.label = 'Cargando...',
    this.description = 'Se está procesando su solicitud',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador animado dentro de un contenedor con sombra/resplandor
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4.5,
                strokeCap: StrokeCap.round,
                color: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Título principal
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subtítulo descriptivo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
