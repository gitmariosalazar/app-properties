// lib/features/properties/presentation/widgets/client/natural_person_form.dart
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/dynamic_field_list.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/utils/validators.dart';

class NaturalPersonForm extends StatefulWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController identificationCtrl;
  final TextEditingController dobCtrl;
  final TextEditingController addressCtrl;
  final List<TextEditingController> emails;
  final List<TextEditingController> phones;
  final VoidCallback onSelectDate;

  const NaturalPersonForm({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.identificationCtrl,
    required this.dobCtrl,
    required this.addressCtrl,
    required this.emails,
    required this.phones,
    required this.onSelectDate,
  });

  @override
  State<NaturalPersonForm> createState() => _NaturalPersonFormState();
}

class _NaturalPersonFormState extends State<NaturalPersonForm> {
  late List<TextEditingController> _emails;
  late List<TextEditingController> _phones;

  @override
  void initState() {
    super.initState();
    _emails = List.from(widget.emails);
    _phones = List.from(widget.phones);

    // Asegurar al menos un campo vacío si no hay
    _ensureMinimumFields();
  }

  @override
  void didUpdateWidget(covariant NaturalPersonForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    final emailsChanged = !_listsEqual(oldWidget.emails, widget.emails);
    final phonesChanged = !_listsEqual(oldWidget.phones, widget.phones);

    if (emailsChanged || phonesChanged) {
      setState(() {
        _emails = List.from(widget.emails);
        _phones = List.from(widget.phones);
        _ensureMinimumFields();
      });
    }
  }

  void _ensureMinimumFields() {
    if (_emails.isEmpty) _emails.add(TextEditingController());
    if (_phones.isEmpty) _phones.add(TextEditingController());
  }

  bool _listsEqual(
    List<TextEditingController> a,
    List<TextEditingController> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormCard(
          title: 'Datos Personales',
          child: Column(
            children: [
              CustomTextField(
                controller: widget.firstNameCtrl,
                label: 'Nombres',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.lastNameCtrl,
                label: 'Apellidos',
                icon: Icons.person,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.addressCtrl,
                label: 'Dirección',
                isRequired: true,
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: widget.identificationCtrl,
                      label: 'Cédula / Pasaporte',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: numberValidator,
                    ),
                  ),
                  context.hSpace(0.04),
                  Expanded(
                    child: CustomTextField(
                      controller: widget.dobCtrl,
                      label: 'Fecha de Nacimiento',
                      icon: Icons.cake,
                      onTap: widget.onSelectDate,
                      readOnly: true,
                      isRequired: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        context.vSpace(0.03),

        // Correos (NO requeridos)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: DynamicFieldList(
            key: ValueKey('emails_${_emails.hashCode}'),
            title: 'Correos Electrónicos',
            controllers: _emails,
            hint: 'email@dominio.com',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
            required: false,
          ),
        ),

        context.vSpace(0.03),

        // Teléfonos (SÍ requeridos)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: DynamicFieldList(
            key: ValueKey('phones_${_phones.hashCode}'),
            title: 'Teléfonos',
            controllers: _phones,
            hint: '+593 99 999 9999',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: phoneValidator,
            required: true, // ← Requerido
          ),
        ),
      ],
    );
  }
}
