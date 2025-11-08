import 'package:app_properties/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label; // Propiedad final
  final Color color;
  final bool loading;
  final double height;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label, // Hacer 'label' required
    required this.color,
    this.loading = false,
    required this.height,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => !loading ? animationController.forward() : null,
      onTapUp: (_) => animationController.reverse(),
      onTapCancel: () => animationController.reverse(),
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.buttonBorderRadius(context),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: ResponsiveUtils.isSmallDevice(context) ? 8 : 12,
                    offset: Offset(
                      0,
                      ResponsiveUtils.isSmallDevice(context) ? 3 : 5,
                    ),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.buttonBorderRadius(context),
                    ),
                  ),
                  elevation: 0,
                  padding: ResponsiveUtils.cardPadding(context).copyWith(
                    left: ResponsiveUtils.scaleWidth(context, 0.04),
                    right: ResponsiveUtils.scaleWidth(context, 0.04),
                  ),
                  minimumSize: Size(double.infinity, height),
                ),
                child: loading
                    ? SizedBox(
                        width: ResponsiveUtils.iconMedium(context),
                        height: ResponsiveUtils.iconMedium(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: ResponsiveUtils.iconSmall(context),
                            color: Colors.white,
                          ),
                          ResponsiveUtils.hSpace(context, 0.03),
                          Text(
                            label,
                            style: ResponsiveUtils.buttonText(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
