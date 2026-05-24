import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class TitledCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double elevation;
  final Icon? bottomRightIcon;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  const TitledCard({
    super.key,
    required this.title,
    required this.children,
    this.elevation = 4,
    this.bottomRightIcon,
    this.backgroundColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.surfaceContainerHighest,
        border: Border.all(
          color: cs.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.cardBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.15),
            blurRadius: elevation,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: ResponsiveUtils.cardPadding(context),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ResponsiveUtils.cardBorderRadius(context),
                ),
                topRight: Radius.circular(
                  ResponsiveUtils.cardBorderRadius(context),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: (titleStyle ?? ResponsiveUtils.titleSmall(context))
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?bottomRightIcon,
              ],
            ),
          ),
          Padding(
            padding: ResponsiveUtils.cardPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
