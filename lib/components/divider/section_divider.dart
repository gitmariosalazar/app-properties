import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const textPrimary = Color(0xFF212121);
}

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
    final effectiveColor = widget.color ?? AppColors.primary.withOpacity(0.1);
    final borderRadius = ResponsiveUtils.cardBorderRadius(context);
    // Ajusta este multiplicador si el texto sigue cortado, prueba con 2.6, 3.0, etc.
    final dividerHeight = ResponsiveUtils.sectionDividerHeight(context) * 2.8;

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
              color: effectiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // La clave: Row (alineación vertical al centro), con Spacer para el texto centrado
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Espacio izquierdo para balancear el icono expand de la derecha
                SizedBox(width: ResponsiveUtils.iconSmall(context)),
                // Texto centrado
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      style: ResponsiveUtils.titleSmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Icono expand/collapse alineado verticalmente al centro
                if (widget.children != null && widget.children!.isNotEmpty)
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Icon(
                          Icons.expand_more,
                          size: ResponsiveUtils.iconSmall(context),
                          color: AppColors.textPrimary,
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
