// lib/components/common/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool isRequired;
  final bool isDense;
  final EdgeInsets? contentPadding;
  final int? minLines;
  final int? maxLines;
  final bool isTextArea;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.isRequired = false,
    this.isDense = false,
    this.contentPadding,
    this.minLines,
    this.maxLines,
    this.isTextArea = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late final GlobalKey<FormFieldState> _fieldKey;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _fieldKey = GlobalKey<FormFieldState>();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final state = _fieldKey.currentState;
    if (state != null && state.hasError) {
      state.didChange(_controller.text);
    }
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      _controller = widget.controller;
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int minLines = widget.isTextArea ? 3 : (widget.minLines ?? 1);
    final int maxLines = widget.isTextArea ? 5 : (widget.maxLines ?? 1);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.isTextArea ? 80 : 40,
        maxHeight: widget.isTextArea ? 160 : 44,
      ),
      child: TextFormField(
        key: _fieldKey,
        controller: _controller,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 11, // Tamaño de texto del input (pequeño y claro)
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          label: widget.isRequired
              ? _buildRequiredLabel(context)
              : _buildLabel(context),
          hintText: widget.isRequired ? null : widget.label,
          hintStyle: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.isTextArea
              ? null
              : Icon(
                  widget.icon,
                  color: AppColors.primary,
                  size: context.iconSmall,
                ),
          filled: true,
          fillColor: widget.readOnly
              ? AppColors.surface.withOpacity(0.2)
              : AppColors.surface.withOpacity(0.4),
          border: _buildBorder(AppColors.primary.withOpacity(0.5)),
          enabledBorder: _buildBorder(AppColors.primary.withOpacity(0.3)),
          focusedBorder: _buildBorder(AppColors.primary, width: 1.5),
          errorBorder: _buildBorder(AppColors.error, width: 1.5),
          isDense: true,
          contentPadding: widget.isTextArea
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 16)
              : (widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          errorStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.error,
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
          errorMaxLines: 1,
        ),
        validator: (value) {
          if (widget.validator != null) {
            final error = widget.validator!(value);
            if (error != null) return error;
          }
          if (widget.isRequired && (value == null || value.trim().isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRequiredLabel(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Text(
      widget.label,
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
