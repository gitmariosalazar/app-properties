// lib/core/components/common/dynamic_field_list.dart
import 'package:app_properties/components/common/compact_add_button.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class DynamicFieldList extends StatefulWidget {
  final String title;
  final List<TextEditingController> controllers;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const DynamicFieldList({
    super.key,
    required this.title,
    required this.controllers,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  State<DynamicFieldList> createState() => _DynamicFieldListState();
}

class _DynamicFieldListState extends State<DynamicFieldList> {
  final List<GlobalKey<FormFieldState>> _fieldKeys = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.controllers.isEmpty) {
      widget.controllers.add(TextEditingController());
    }

    _fieldKeys.clear();
    for (var i = 0; i < widget.controllers.length; i++) {
      final key = GlobalKey<FormFieldState>();
      _fieldKeys.add(key);
    }
  }

  void _addField() {
    setState(() {
      widget.controllers.add(TextEditingController());
      _fieldKeys.add(GlobalKey<FormFieldState>());
    });
  }

  void _removeField(int index) {
    if (widget.controllers.length > 1) {
      setState(() {
        widget.controllers.removeAt(index);
        _fieldKeys.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    // NO HAGAS NADA AQUÍ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: context.iconSmall,
                  ),
                  context.hSpace(0.01),
                  Text(
                    widget.title,
                    style: context.titleExtraSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              CompactAddButton(onPressed: _addField),
            ],
          ),
          context.vSpace(0.02),

          ...widget.controllers.asMap().entries.map((entry) {
            final index = entry.key;
            final ctrl = entry.value;
            final fieldKey = _fieldKeys[index];

            return Padding(
              key: ValueKey('field_$index'),
              padding: EdgeInsets.only(bottom: context.smallSpacing * 2.7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextField(
                      key: fieldKey,
                      controller: ctrl,
                      label: widget.hint,
                      icon: widget.icon,
                      keyboardType: widget.keyboardType,
                      validator: widget.validator,
                      isRequired: false,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minLines: 1,
                      maxLines: 1,
                    ),
                  ),
                  if (widget.controllers.length > 1)
                    Padding(
                      padding: EdgeInsets.only(
                        left: context.smallSpacing * 0.6,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_forever,
                          color: AppColors.error,
                          size: context.iconMedium,
                        ),
                        onPressed: () => _removeField(index),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withOpacity(0.2),
                          padding: EdgeInsets.all(context.smallSpacing * 0.8),
                          shape: const CircleBorder(),
                          minimumSize: const Size(38, 38),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
