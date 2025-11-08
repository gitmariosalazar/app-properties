// lib/core/components/common/form_card.dart
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class FormCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const FormCard({super.key, this.title, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.cardBorderRadiusValue),
        side: const BorderSide(color: AppColors.border),
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
                      color: AppColors.primary,
                      size: context.iconSmall,
                    ),
                    context.hSpace(0.015),
                    Text(
                      title!,
                      style: context.titleExtraSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
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
