// lib/features/properties/presentation/widgets/property/property_form.dart
import 'package:app_properties/features/properties/list/domain/entities/property.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/utils/validators.dart';

class PropertyForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // === FORMULARIO DE EDICIÓN ===
        _buildEditForm(context),
        context.vSpace(0.02),

        // === LISTA DE PROPIEDADES ===
        _buildPropertiesList(context),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      children: [
        FormCard(
          title: 'Datos del Predio',
          child: Column(
            children: [
              CustomTextField(
                controller: cadastralKeyCtrl,
                label: 'Clave Catastral',
                icon: Icons.key,
                readOnly: true,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: propertyAddressCtrl,
                label: 'Dirección',
                icon: Icons.home,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: alleywayCtrl,
                label: 'Callejón',
                icon: Icons.streetview,
              ),
            ],
          ),
        ),
        /*
        context.vSpace(0.0),
        FormCard(
          title: 'Áreas y Avalúos',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: landAreaCtrl,
                      label: 'Área Terreno (m²)',
                      icon: Icons.landscape,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  context.hSpace(0.025),
                  Expanded(
                    child: CustomTextField(
                      controller: constructionAreaCtrl,
                      label: 'Área Construcción (m²)',
                      icon: Icons.home_repair_service,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: landValueCtrl,
                      label: 'Valor Terreno',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  context.hSpace(0.025),
                  Expanded(
                    child: CustomTextField(
                      controller: constructionValueCtrl,
                      label: 'Valor Construcción',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),*/
      ],
    );
  }

  Widget _buildPropertiesList(BuildContext context) {
    if (properties == null) return const SizedBox.shrink();

    if (properties!.isEmpty) {
      return FormCard(
        title: 'Propiedades',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Text('No se encontraron propiedades.', style: context.bodyMedium),
            ],
          ),
        ),
      );
    }

    return FormCard(
      title: 'Propiedades Encontradas (${properties!.length})',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: properties!.length,
        itemBuilder: (context, index) {
          final property = properties![index];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ExpansionTile(
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.grey[50],
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.home, color: Colors.blue),
                  ),
                  title: Text(
                    property.propertyAddress,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Clave: ${property.propertyCadastralKey}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey[50],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //_buildDetailRow('ID', property.propertyId),
                          _buildDetailRow('Sector', property.propertySector),
                          _buildDetailRow('Tipo', property.propertyTypeName),
                          _buildDetailRow(
                            'Callejón',
                            property.propertyAlleyway,
                          ),
                          /*
                          _buildDetailRow(
                            'Altitud',
                            property.propertyAltitude != null
                                ? '${property.propertyAltitude!.toStringAsFixed(2)} m'
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Precisión',
                            property.propertyPrecision != null
                                ? '${property.propertyPrecision!.toStringAsFixed(2)} m'
                                : 'N/A',
                          ),
                          _buildDetailRow(
                            'Coordenadas',
                            property.propertyCoordinates ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Referencia',
                            property.propertyReference ?? 'N/A',
                          ),
                          _buildDetailRow(
                            'Zona Geométrica',
                            property.propertyGeometricZone ?? 'N/A',
                          ),
                          */
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Aquí tomamos SOLO los valores del property seleccionado
                                cadastralKeyCtrl.text =
                                    property.propertyCadastralKey ?? '';
                                propertyAddressCtrl.text =
                                    property.propertyAddress ?? '';
                                alleywayCtrl.text =
                                    property.propertyAlleyway ?? '';
                                landAreaCtrl.text = '';
                                constructionAreaCtrl.text = '';
                                landValueCtrl.text = '';
                                constructionValueCtrl.text = '';

                                // Opcional: notificar al padre si necesitas
                                onPropertySelected?.call(property);
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Seleccionar Predio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
