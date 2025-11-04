import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

/// Layout that switches between [mobile] and [tablet] widgets depending on device type.
/// Uses context-based responsive utils for robustness.
/// - [mobile]: Widget for mobile/small screens (required).
/// - [tablet]: Widget for tablet/large screens (optional, falls back to [mobile] if null).
class ScreenTypeLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const ScreenTypeLayout({super.key, required this.mobile, this.tablet});

  @override
  Widget build(BuildContext context) {
    // Decide based on current device type (never store context globally).
    return ResponsiveUtils.isTablet(context) && tablet != null
        ? tablet!
        : mobile;
  }
}

/// A responsive row that switches to a column on small devices, or stays as a row/tablet layout otherwise.
/// - [children]: List of widgets to display.
/// - [mainAxisAlignment]: Row main axis alignment.
/// - [crossAxisAlignment]: Row cross axis alignment.
/// - [rowSpacing]: Spacing between children in row (if omitted, uses ResponsiveUtils spacing).
/// - [forceRow]: If true, always forces Row layout.
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? rowSpacing;
  final bool forceRow;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.rowSpacing,
    this.forceRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallDevice = ResponsiveUtils.isSmallDevice(context);

    // On small devices (and not forced), use a Column with spacing.
    if (isSmallDevice && !forceRow && children.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key < children.length - 1
                      ? ResponsiveUtils.smallSpacing(context)
                      : 0,
                ),
                child: entry.value,
              ),
            )
            .toList(),
      );
    }

    // On larger screens or forceRow, use a Row with spacing and expanded children.
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .asMap()
          .entries
          .map(
            (entry) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key < children.length - 1
                      ? rowSpacing ?? ResponsiveUtils.smallSpacing(context)
                      : 0,
                ),
                child: entry.value,
              ),
            ),
          )
          .toList(),
    );
  }
}
