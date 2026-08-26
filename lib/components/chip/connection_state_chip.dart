import 'package:flutter/material.dart';
import 'color_chip.dart';

/// A shared component for displaying Connection States (Estados de Acometida),
/// similar to its React counterpart.
class ConnectionStateChip extends StatelessWidget {
  /// The connection state ID (id_estado)
  final int? statusId;

  /// The connection state name (nombre)
  final String? statusName;

  /// Size of the chip.
  final ColorChipSize size;

  /// Visual style variant of the chip.
  final ColorChipVariant variant;

  /// Callback when the chip is tapped.
  final VoidCallback? onTap;

  /// Whether to display a dot indicator.
  final bool withDot;

  const ConnectionStateChip({
    super.key,
    this.statusId,
    this.statusName,
    this.size = ColorChipSize.md,
    this.variant = ColorChipVariant.soft,
    this.onTap,
    this.withDot = true,
  });

  @override
  Widget build(BuildContext context) {
    // Identifier priority: statusId over statusName
    final identifier = statusId ?? statusName;

    if (identifier == null) {
      return ColorChip(
        label: 'Desconocido',
        color: Theme.of(context).disabledColor,
        size: size,
        variant: variant,
        onTap: onTap,
        withDot: withDot,
      );
    }

    String label = 'Desconocido';
    ColorChipStatus? chipStatus;

    if (identifier is int) {
      if (identifier == 1) {
        label = 'Activo';
        chipStatus = ColorChipStatus.success;
      } else {
        label = 'Inactivo';
        chipStatus = ColorChipStatus.warning;
      }
    } else if (identifier is String) {
      final nameLower = identifier.toLowerCase();
      label = identifier;
      
      if (nameLower.contains('activ')) {
        chipStatus = ColorChipStatus.success;
      } else if (nameLower.contains('inactiv') || nameLower.contains('suspend')) {
        chipStatus = ColorChipStatus.warning;
      } else if (nameLower.contains('cortad')) {
        chipStatus = ColorChipStatus.error;
      } else {
        chipStatus = ColorChipStatus.info;
      }
    }

    return ColorChip(
      label: label,
      status: chipStatus,
      size: size,
      variant: variant,
      onTap: onTap,
      withDot: withDot,
    );
  }
}
