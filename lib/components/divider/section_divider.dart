// lib/components/divider/section_divider.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

/// SRP: collapsible section header.
/// All colors resolved from [ColorScheme] — adapts to light/dark.
class MinimalSectionDivider extends StatefulWidget {
  final String title;
  final Color? color;
  final List<Widget>? children;

  const MinimalSectionDivider({
    super.key,
    required this.title,
    this.color,
    this.children,
  });

  @override
  State<MinimalSectionDivider> createState() => _MinimalSectionDividerState();
}

class _MinimalSectionDividerState extends State<MinimalSectionDivider>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // If a custom color is given, use it; otherwise use primary with low opacity
    final headerBg = widget.color ?? cs.primary.withValues(alpha: 0.10);
    final textColor = cs.onSurface;
    final iconColor = cs.onSurface;
    final borderRadius = ResponsiveUtils.cardBorderRadius(context);
    final dividerHeight =
        ResponsiveUtils.sectionDividerHeight(context) * 2.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: widget.children != null && widget.children!.isNotEmpty
              ? _toggleExpand
              : null,
          child: Container(
            height: dividerHeight,
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUtils.mediumSpacing(context),
              horizontal: ResponsiveUtils.mediumSpacing(context),
            ),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: ResponsiveUtils.iconSmall(context)),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: ResponsiveUtils.titleSmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        shadows: [
                          Shadow(
                            color: cs.shadow.withValues(alpha: 0.12),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (widget.children != null && widget.children!.isNotEmpty)
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.expand_more,
                          size: ResponsiveUtils.iconSmall(context),
                          color: iconColor,
                        ),
                      );
                    },
                  )
                else
                  SizedBox(width: ResponsiveUtils.iconSmall(context)),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (!_isExpanded ||
                widget.children == null ||
                widget.children!.isEmpty) {
              return const SizedBox.shrink();
            }
            return ClipRect(
              child: AnimatedOpacity(
                opacity: _fadeAnimation.value,
                duration: const Duration(milliseconds: 400),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.mediumSpacing(context),
                      horizontal: ResponsiveUtils.mediumSpacing(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
