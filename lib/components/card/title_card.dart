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
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.cardBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.25),
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
              color: theme.colorScheme.primary.withOpacity(0.1),
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
                          color: theme.colorScheme.primary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (bottomRightIcon != null) bottomRightIcon!,
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
