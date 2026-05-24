// lib/features/properties/presentation/widgets/property/property_form.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/features/properties/search/domain/entities/property.dart';

/// Property selection & edit form. All colors from [ColorScheme] — dark/light adaptive.
class PropertyForm extends StatefulWidget {
  final TextEditingController propertyCadastralKeyCtrl;
  final TextEditingController propertyAddressCtrl;
  final TextEditingController alleywayCtrl;
  final TextEditingController landAreaCtrl;
  final TextEditingController constructionAreaCtrl;
  final TextEditingController landValueCtrl;
  final TextEditingController constructionValueCtrl;

  final List<PropertyEntity>? properties;
  final void Function(PropertyEntity)? onPropertySelected;

  const PropertyForm({
    super.key,
    required this.propertyCadastralKeyCtrl,
    required this.propertyAddressCtrl,
    required this.alleywayCtrl,
    required this.landAreaCtrl,
    required this.constructionAreaCtrl,
    required this.landValueCtrl,
    required this.constructionValueCtrl,
    this.properties,
    this.onPropertySelected,
  });

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  PropertyEntity? _selectedProperty;

  @override
  void initState() {
    super.initState();
    _detectInitialSelection();
  }

  void _detectInitialSelection() {
    final key = widget.propertyCadastralKeyCtrl.text;
    if (key.isNotEmpty && key != 'N/A' && widget.properties != null) {
      final match = widget.properties!.firstWhere(
        (p) => p.propertyCadastralKey == key,
        orElse: () => widget.properties!.first,
      );
      if (match.propertyCadastralKey == key) {
        _selectedProperty = match;
      }
    }
  }

  void _selectProperty(PropertyEntity property) {
    setState(() {
      _selectedProperty = property;
    });
    widget.propertyCadastralKeyCtrl.text = property.propertyCadastralKey;
    widget.propertyAddressCtrl.text = property.propertyAddress;
    widget.alleywayCtrl.text = property.propertyAlleyway;
    widget.landAreaCtrl.text = '';
    widget.constructionAreaCtrl.text = '';
    widget.landValueCtrl.text = '';
    widget.constructionValueCtrl.text = '';
    widget.onPropertySelected?.call(property);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditForm(context),
        context.vSpace(0.03),
        _buildPropertiesList(context),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use a semantic green — a fixed color that reads well in both modes
    const selectedGreen = Color(0xFF2E7D32);
    const selectedGreenLight = Color(0xFFE8F5E9);

    return FormCard(
      title: 'Datos del Predio',
      child: Column(
        children: [
          CustomTextField(
            controller: widget.propertyCadastralKeyCtrl,
            label: 'Clave Catastral',
            icon: _selectedProperty != null
                ? Icons.check_circle
                : Icons.vpn_key,
            readOnly: true,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: widget.propertyAddressCtrl,
            label: 'Dirección del Predio',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: widget.alleywayCtrl,
            label: 'Callejón / Pasaje',
            icon: Icons.streetview,
            isRequired: false,
          ),
          const SizedBox(height: 16),

          // Selected indicator
          if (_selectedProperty != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.brightness == Brightness.dark
                    ? selectedGreen.withValues(alpha: 0.2)
                    : selectedGreenLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selectedGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: selectedGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Predio seleccionado: ${_selectedProperty!.propertyCadastralKey}',
                    style: context.bodySmall.copyWith(
                      color: selectedGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertiesList(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    // Semantic selected green
    const selGreen = Color(0xFF2E7D32);
    const selGreenBg = Color(0xFFE8F5E9);
    const selGreenBgDark = Color(0xFF1B3A1B);

    if (widget.properties == null || widget.properties!.isEmpty) {
      return FormCard(
        title: 'Propiedades',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.tertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No se encontraron propiedades asociadas al cliente.',
                  style: context.bodyMedium.copyWith(color: cs.tertiary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FormCard(
      title: 'Propiedades Encontradas (${widget.properties!.length})',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.properties!.length,
        itemBuilder: (context, index) {
          final property = widget.properties![index];
          final isSelected =
              _selectedProperty?.propertyCadastralKey ==
              property.propertyCadastralKey;

          final cardBg = isSelected
              ? (isDark ? selGreenBgDark : selGreenBg)
              : null; // null → Card default from theme
          final textColorMain = isSelected ? selGreen : cs.onSurface;
          final textColorSub = isSelected ? selGreen : cs.onSurfaceVariant;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selGreen.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Card(
              elevation: isSelected ? 6 : 2,
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(color: selGreen, width: 1.5)
                    : BorderSide.none,
              ),
              child: ExpansionTile(
                backgroundColor: cardBg,
                collapsedBackgroundColor: isSelected
                    ? cardBg
                    : cs.surfaceContainerHighest,
                leading: CircleAvatar(
                  backgroundColor: (isSelected ? selGreen : cs.primary)
                      .withValues(alpha: 0.12),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.home,
                    color: isSelected ? selGreen : cs.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  property.propertyAddress,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textColorMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Clave: ${property.propertyCadastralKey}',
                  style: TextStyle(
                    color: textColorSub,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    color: cardBg ?? cs.surfaceContainerHighest,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          context,
                          'Sector',
                          property.propertySector,
                        ),
                        _buildDetailRow(
                          context,
                          'Tipo',
                          property.propertyTypeName,
                        ),
                        _buildDetailRow(
                          context,
                          'Callejón',
                          property.propertyAlleyway,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSelected
                                ? null
                                : () => _selectProperty(property),
                            icon: Icon(
                              isSelected ? Icons.check : Icons.touch_app,
                              size: 18,
                            ),
                            label: Text(
                              isSelected
                                  ? 'Seleccionado'
                                  : 'Seleccionar Predio',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? cs.surfaceContainerHighest
                                  : selGreen,
                              foregroundColor: isSelected
                                  ? cs.onSurfaceVariant
                                  : Colors.white,
                              elevation: isSelected ? 0 : 2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    final cs = Theme.of(context).colorScheme;
    final displayValue = value?.isNotEmpty == true ? value! : 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                color: displayValue == 'N/A'
                    ? cs.onSurfaceVariant
                    : cs.onSurface,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
