// lib/components/common/compact_add_button.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

/// SRP: a compact "add another" button.
/// Colors derived from [ColorScheme.secondary] — adapts to light/dark.
class CompactAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CompactAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.add_circle_outline,
        color: cs.secondary,
        size: context.iconExtraSmall,
      ),
      label: Text(
        'Agregar otro',
        style: context.bodySmall.copyWith(
          color: cs.secondary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: cs.secondary.withValues(alpha: 0.12),
        padding: EdgeInsets.symmetric(
          horizontal: context.smallSpacing * 0.9,
          vertical: context.extraSmallSpacing * 0.7,
        ),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
        ),
      ),
    );
  }
}
