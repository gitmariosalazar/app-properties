// lib/components/common/form_card.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

/// SRP: renders a themed card container for form sections.
/// All colors resolved from [ColorScheme] — adapts to light/dark.
class FormCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FormCard({super.key, this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: context.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.cardBorderRadiusValue),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: padding ?? context.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: context.smallSpacing * 2.2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.cardBorderRadiusValue - 2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: cs.primary,
                      size: context.iconSmall,
                    ),
                    context.hSpace(0.015),
                    Text(
                      title!,
                      style: context.titleExtraSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
