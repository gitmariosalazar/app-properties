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
  // Copias locales para forzar rebuild
  late List<TextEditingController> _emails;
  late List<TextEditingController> _phones;

  @override
  void initState() {
    super.initState();
    _emails = widget.emails;
    _phones = widget.phones;

    // Forzar rebuild después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _emails = widget.emails;
          _phones = widget.phones;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant NaturalPersonForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambian las listas (desde el padre), actualizamos
    final emailsChanged =
        oldWidget.emails.length != widget.emails.length ||
        oldWidget.emails != widget.emails;

    final phonesChanged =
        oldWidget.phones.length != widget.phones.length ||
        oldWidget.phones != widget.phones;

    if (emailsChanged || phonesChanged) {
      if (mounted) {
        setState(() {
          _emails = widget.emails;
          _phones = widget.phones;
        });
      }
    }
  }

  @override
  void dispose() {
    // No hacemos dispose aquí porque los controladores son del padre
    super.dispose();
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
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.lastNameCtrl,
                label: 'Apellidos',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: widget.addressCtrl,
                label: 'Dirección',
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
                      validator: numberValidator,
                    ),
                  ),
                  context.hSpace(0.04),
                  Expanded(
                    child: CustomTextField(
                      controller: widget.dobCtrl,
                      label: 'Fecha de Nacimiento',
                      icon: Icons.cake,
                      readOnly: true,
                      onTap: widget.onSelectDate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        context.vSpace(0.03),

        // Correos
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: DynamicFieldList(
            key: ValueKey('emails_${_emails.length}'),
            title: 'Correos Electrónicos',
            controllers: _emails,
            hint: 'email@dominio.com',
            icon: Icons.email,
          ),
        ),

        context.vSpace(0.03),

        // Teléfonos
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: DynamicFieldList(
            key: ValueKey('phones_${_phones.length}'),
            title: 'Teléfonos',
            controllers: _phones,
            hint: '+593 99 999 9999',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: phoneValidator,
          ),
        ),
      ],
    );
  }
}
