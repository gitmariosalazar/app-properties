import 'package:app_properties/features/properties/search/domain/entities/last_reading.dart';
import 'package:flutter/material.dart';

/// Tabla reutilizable del historial de lecturas de medidor.
///
/// Recibe directamente [List<LastReadingEntity>] para ser completamente
/// independiente de cualquier entidad padre (ConnectionEntity, etc.),
/// cumpliendo con ISP (Interface Segregation Principle) y DIP
/// (Dependency Inversion Principle) al depender solo de la abstracción
/// del dominio.
///
/// Uso básico:
/// ```dart
/// ReadingsHistoryTable(readings: connection.lastReadings)
/// ```
///
/// Limitar a las últimas N lecturas:
/// ```dart
/// ReadingsHistoryTable(readings: connection.lastReadings, limit: 5)
/// ```
class ReadingsHistoryTable extends StatelessWidget {
  /// Lista de lecturas proveniente del dominio.
  final List<LastReadingEntity>? readings;

  /// Número máximo de lecturas a mostrar.
  /// Si es null, se muestran todas.
  final int? limit;

  const ReadingsHistoryTable({
    super.key,
    required this.readings,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final displayedReadings = _resolveReadings();

    if (displayedReadings == null || displayedReadings.isEmpty) {
      return _buildEmptyState(theme, cs);
    }

    return _buildTable(theme, cs, displayedReadings);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  List<LastReadingEntity>? _resolveReadings() {
    if (readings == null) return null;
    if (limit != null) return readings!.take(limit!).toList();
    return readings;
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            color: theme.hintColor.withValues(alpha: 0.4),
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Sin lecturas registradas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(
    ThemeData theme,
    ColorScheme cs,
    List<LastReadingEntity> rows,
  ) {
    const headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Fecha',
                    style: headerStyle.copyWith(color: cs.primary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Actual',
                    textAlign: TextAlign.center,
                    style: headerStyle.copyWith(color: cs.primary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Anterior',
                    textAlign: TextAlign.center,
                    style: headerStyle.copyWith(color: cs.primary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Consumo',
                    textAlign: TextAlign.center,
                    style: headerStyle.copyWith(color: cs.primary),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Novedad',
                    textAlign: TextAlign.right,
                    style: headerStyle,
                  ),
                ),
              ],
            ),
          ),

          // ── Rows ─────────────────────────────────────────────────────────────
          ...List.generate(rows.length, (index) {
            return _ReadingRow(
              reading: rows[index],
              index: index,
              total: rows.length,
            );
          }),
        ],
      ),
    );
  }
}

// =============================================================================
// _ReadingRow — widget privado con SRP: solo renderiza una fila
// =============================================================================

class _ReadingRow extends StatelessWidget {
  final LastReadingEntity reading;
  final int index;
  final int total;

  const _ReadingRow({
    required this.reading,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEven = index % 2 == 0;
    final consumption =
        (reading.readingValueCurrent ?? 0) - (reading.readingValuePreview ?? 0);
    final isLast = index == total - 1;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: isEven
                ? Colors.transparent
                : cs.primary.withValues(alpha: 0.03),
            borderRadius: isLast
                ? const BorderRadius.vertical(bottom: Radius.circular(5))
                : BorderRadius.zero,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date + month
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(reading.readingDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    if (reading.readingMonth != null)
                      Text(
                        reading.readingMonth!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),

              // Current reading
              Expanded(
                flex: 2,
                child: Text(
                  '${reading.readingValueCurrent?.toStringAsFixed(0) ?? "-"} m³',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),

              // Preview reading
              Expanded(
                flex: 2,
                child: Text(
                  '${reading.readingValuePreview?.toStringAsFixed(0) ?? "-"} m³',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),

              // Consumption delta chip
              Expanded(
                flex: 2,
                child: _ConsumptionChip(consumption: consumption),
              ),

              // Novelty badge
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _NoveltyBadge(novelty: reading.novelty),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 14,
            endIndent: 14,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: 0.25,
                ),
          ),
      ],
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// =============================================================================
// _ConsumptionChip — SRP: solo muestra el delta de consumo
// =============================================================================

class _ConsumptionChip extends StatelessWidget {
  final double consumption;

  const _ConsumptionChip({required this.consumption});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPositive = consumption > 0;
    final color = isPositive ? const Color(0xFF10B981) : cs.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${isPositive ? "+" : ""}${consumption.toStringAsFixed(0)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// _NoveltyBadge — SRP: solo clasifica y muestra la novedad
// =============================================================================

class _NoveltyBadge extends StatelessWidget {
  final String? novelty;

  const _NoveltyBadge({required this.novelty});

  @override
  Widget build(BuildContext context) {
    if (novelty == null || novelty!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final upper = novelty!.toUpperCase();

    final Color bgColor;
    final Color textColor;

    if (upper.contains('NORMAL')) {
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
      textColor = const Color(0xFF059669);
    } else if (upper.contains('BAJO') || upper.contains('LOW')) {
      bgColor = Colors.amber.withValues(alpha: 0.15);
      textColor = Colors.amber.shade800;
    } else if (upper.contains('ALTO') || upper.contains('HIGH')) {
      bgColor = cs.error.withValues(alpha: 0.12);
      textColor = cs.error;
    } else if (upper.contains('INICIAL') || upper.contains('CAMBIO')) {
      bgColor = cs.primary.withValues(alpha: 0.1);
      textColor = cs.primary;
    } else {
      bgColor = cs.surfaceContainerHighest.withValues(alpha: 0.5);
      textColor = theme.hintColor;
    }

    final label = novelty!.length > 18
        ? '${novelty!.substring(0, 15)}…'
        : novelty!;

    return Tooltip(
      message: novelty!,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 9,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
