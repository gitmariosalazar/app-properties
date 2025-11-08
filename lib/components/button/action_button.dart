// lib/core/components/button/action_button.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool loading;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      label: Text(label),
      icon: Icon(icon, size: context.iconSmall),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: context.buttonBorderRadiusValue,
        ),
      ),
    );
  }
}
