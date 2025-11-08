// lib/features/properties/presentation/widgets/property/property_form.dart
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/features/properties/list/domain/entities/property.dart';

class PropertyForm extends StatefulWidget {
  final TextEditingController cadastralKeyCtrl;
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
    required this.cadastralKeyCtrl,
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
    // Detectar si ya hay datos precargados → marcar como seleccionado
    _detectInitialSelection();
  }

  void _detectInitialSelection() {
    final key = widget.cadastralKeyCtrl.text;
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

    // Actualizar todos los campos
    widget.cadastralKeyCtrl.text = property.propertyCadastralKey;
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
        // === FORMULARIO DE EDICIÓN (SIEMPRE VISIBLE) ===
        _buildEditForm(context),

        context.vSpace(0.03),

        // === LISTA DE PROPIEDADES ===
        _buildPropertiesList(context),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return FormCard(
      title: 'Datos del Predio',
      child: Column(
        children: [
          // Clave Catastral
          CustomTextField(
            controller: widget.cadastralKeyCtrl,
            label: 'Clave Catastral',
            icon: _selectedProperty != null
                ? Icons.check_circle
                : Icons.vpn_key,
            readOnly: true,
          ),
          const SizedBox(height: 12),

          // Dirección
          CustomTextField(
            controller: widget.propertyAddressCtrl,
            label: 'Dirección del Predio',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 12),

          // Callejón
          CustomTextField(
            controller: widget.alleywayCtrl,
            label: 'Callejón / Pasaje',
            icon: Icons.streetview,
            isRequired: false,
          ),
          const SizedBox(height: 16),

          /*
          // Áreas y Avalúos (opcionales pero visibles)
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.landAreaCtrl,
                  label: 'Área Terreno (m²)',
                  icon: Icons.landscape,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: false,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.constructionAreaCtrl,
                  label: 'Área Construcción (m²)',
                  icon: Icons.home_repair_service,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: widget.landValueCtrl,
                  label: 'Valor Terreno (\$)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: false,
                ),
              ),
              context.hSpace(0.025),
              Expanded(
                child: CustomTextField(
                  controller: widget.constructionValueCtrl,
                  label: 'Valor Construcción (\$)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: false,
                ),
              ),
            ],
          ),
          */

          // Indicador de selección
          if (_selectedProperty != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Predio seleccionado: ${_selectedProperty!.propertyCadastralKey}',
                    style: context.bodySmall.copyWith(
                      color: Colors.green[700],
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
    if (widget.properties == null || widget.properties!.isEmpty) {
      return FormCard(
        title: 'Propiedades',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No se encontraron propiedades asociadas al cliente.',
                  style: context.bodyMedium.copyWith(color: Colors.orange[700]),
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

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Card(
              elevation: isSelected ? 6 : 2,
              color: isSelected ? Colors.green[50] : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: Colors.green, width: 1.5)
                    : BorderSide.none,
              ),
              child: ExpansionTile(
                backgroundColor: isSelected ? Colors.green[50] : Colors.white,
                collapsedBackgroundColor: isSelected
                    ? Colors.green[50]
                    : Colors.grey[50],
                leading: CircleAvatar(
                  backgroundColor:
                      (isSelected
                              ? Colors.green
                              : Theme.of(context).primaryColor)
                          .withOpacity(0.1),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.home,
                    color: isSelected ? Colors.green[700] : Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  property.propertyAddress,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isSelected ? Colors.green[800] : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Clave: ${property.propertyCadastralKey}',
                  style: TextStyle(
                    color: isSelected ? Colors.green[700] : Colors.grey[700],
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : null,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    color: isSelected ? Colors.green[50] : Colors.grey[50],
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Sector', property.propertySector),
                        _buildDetailRow('Tipo', property.propertyTypeName),
                        _buildDetailRow('Callejón', property.propertyAlleyway),

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
                                  ? Colors.grey[400]
                                  : Colors.green,
                              foregroundColor: Colors.white,
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

  Widget _buildDetailRow(String label, String? value) {
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                color: displayValue == 'N/A'
                    ? Colors.grey[600]
                    : Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
