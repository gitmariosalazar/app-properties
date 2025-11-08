// lib/features/properties/presentation/widgets/client/company_form.dart
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/dynamic_field_list.dart';
import 'package:app_properties/utils/validators.dart';

class CompanyForm extends StatelessWidget {
  final TextEditingController companyNameCtrl;
  final TextEditingController socialReasonCtrl;
  final TextEditingController rucCtrl;
  final TextEditingController companyAddressCtrl;
  final List<TextEditingController> emails;
  final List<TextEditingController> phones;

  const CompanyForm({
    super.key,
    required this.companyNameCtrl,
    required this.socialReasonCtrl,
    required this.rucCtrl,
    required this.companyAddressCtrl,
    required this.emails,
    required this.phones,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormCard(
          title: 'Datos de la Empresa',
          child: Column(
            children: [
              CustomTextField(
                controller: companyNameCtrl,
                label: 'Razón Social',
                icon: Icons.business,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: socialReasonCtrl,
                label: 'Nombre Comercial',
                icon: Icons.store,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: rucCtrl,
                label: 'RUC',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                validator: numberValidator,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: companyAddressCtrl,
                label: 'Dirección',
                icon: Icons.location_on,
              ),
            ],
          ),
        ),
        context.vSpace(0.0),
        DynamicFieldList(
          title: 'Correos de la Empresa',
          controllers: emails,
          hint: 'info@empresa.com',
          icon: Icons.email,
        ),
        context.vSpace(0.0),
        DynamicFieldList(
          title: 'Teléfonos de la Empresa',
          controllers: phones,
          hint: '+593 2 123 4567',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
        ),
      ],
    );
  }
}
