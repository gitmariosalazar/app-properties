// lib/features/incidents/presentation/pages/solve_incident_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_state.dart';
import 'package:app_properties/components/button/widget_button.dart';

class SolveIncidentScreen extends StatefulWidget {
  final String incidentId;
  final String incidentCode;

  const SolveIncidentScreen({
    super.key,
    required this.incidentId,
    required this.incidentCode,
  });

  @override
  State<SolveIncidentScreen> createState() => _SolveIncidentScreenState();
}

class _SolveIncidentScreenState extends State<SolveIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  bool _chargeToUser = false;
  List<File> _images = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al obtener imagen: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final loginState = context.read<LoginCubit>().state;
    if (loginState is! LoginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró sesión activa.')),
      );
      return;
    }

    final resolverUserId = loginState.user.id;
    final double cost = double.tryParse(_costController.text.trim()) ?? 0.0;

    final request = ResolveIncidentRequest(
      description: _descriptionController.text.trim(),
      repairCost: cost,
      chargeToUser: _chargeToUser,
      images: _images,
    );

    context.read<IncidentCubit>().resolveIncident(
      incidentId: widget.incidentId,
      resolverUserId: resolverUserId,
      request: request,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<IncidentCubit, IncidentState>(
      listener: (context, state) {
        if (state is IncidentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade800,
            ),
          );
        } else if (state is IncidentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green.shade800,
            ),
          );
          // Return to previous screen and potentially trigger a refresh
          context.pop(true);
        }
      },
      builder: (context, state) {
        final isLoading = state is IncidentLoading;

        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            title: const Text('Resolver Incidencia'),
            elevation: 0,
            centerTitle: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: cs.outlineVariant, height: 1),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles de la Solución',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete el formulario para marcar la incidencia Nº ${widget.incidentCode} como resuelta.',
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Descripción de la resolución',
                      hintText:
                          'Ej. Se reparó la fuga de agua en la tubería principal...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Cost Field
                  TextFormField(
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Costo de Reparación (\$)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingrese un costo válido (use 0 si no hay costo)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Charge to User Switch
                  Material(
                    color: cs.surfaceContainerHighest.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SwitchListTile(
                      title: const Text(
                        '¿Cobrar al usuario?',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Marque si el costo será cargado a la planilla del usuario',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _chargeToUser,
                      onChanged: (val) {
                        setState(() {
                          _chargeToUser = val;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photos Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Evidencia Fotográfica',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${_images.length}/3',
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_images.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aún no hay fotos adjuntas',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          onPressed: _images.length >= 3 || isLoading
                              ? null
                              : () => _pickImage(ImageSource.camera),
                          icon: Icons.camera_alt_rounded,
                          label: 'Tomar Foto',
                          style: ActionButtonStyle.outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          onPressed: _images.length >= 3 || isLoading
                              ? null
                              : () => _pickImage(ImageSource.gallery),
                          icon: Icons.photo_rounded,
                          label: 'Galería',
                          style: ActionButtonStyle.outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ActionButton(
                      onPressed: isLoading ? null : _submit,
                      icon: Icons.check_circle_rounded,
                      label: 'Guardar y Resolver',
                      loading: isLoading,
                      size: ActionButtonSize.large,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
