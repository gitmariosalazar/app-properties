import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/components/widgets/mic_suffix_button.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/change_meter_usecase.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/change_meter_request.dart'
    as cmr;
import 'package:app_properties/components/button/widget_button.dart';

class UpdateMeterNumberFormScreen extends StatefulWidget {
  final ConnectionWithPropertiesEntity connection;

  const UpdateMeterNumberFormScreen({super.key, required this.connection});

  @override
  State<UpdateMeterNumberFormScreen> createState() =>
      _UpdateMeterNumberFormScreenState();
}

class _UpdateMeterNumberFormScreenState
    extends State<UpdateMeterNumberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newMeterController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _oldMeterReadingController = TextEditingController();
  final _newMeterInitialReadingController = TextEditingController();
  final _newMeterCurrentReadingController = TextEditingController();

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _newMeterController.dispose();
    _descriptionController.dispose();
    _oldMeterReadingController.dispose();
    _newMeterInitialReadingController.dispose();
    _newMeterCurrentReadingController.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al obtener imagen: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final validImages = _images.where((file) => file.existsSync()).toList();
      final numeroMedidor = _newMeterController.text.trim();
      final currentConn = widget.connection;

      final meterDetail = cmr.MeterChangeDetail(
        numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
        claveCatastral: currentConn.connectionCadastralKey,
        observaciones: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        medidorAnterior: cmr.OldMeterData(
          numeroMedidor: currentConn.connectionMeterNumber,
          ultimaLectura: double.tryParse(
            _oldMeterReadingController.text.trim(),
          ),
          fechaUltimaLectura: DateTime.now().toIso8601String(),
        ),
        medidorNuevo: cmr.NewMeterData(
          numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
          lecturaAnterior: double.tryParse(
            _newMeterInitialReadingController.text.trim(),
          ),
          lecturaActual: double.tryParse(
            _newMeterCurrentReadingController.text.trim(),
          ),
          fechaUltimaLectura: DateTime.now().toIso8601String(),
        ),
      );

      final changeMeterReq = cmr.ChangeMeterRequest(
        connectionId: currentConn.connectionId,
        changeDetail: meterDetail,
        images: validImages,
        imageDescriptions: [],
      );

      final useCase = di.sl<ChangeMeterUseCase>();
      await useCase.call(changeMeterReq);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Número de medidor actualizado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final cs = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al actualizar: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final conn = widget.connection;
    final clientName = conn.person != null
        ? '${conn.person!.firstName} ${conn.person!.lastName}'
        : conn.company?.businessName ?? 'Sin Cliente Asociado';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Actualizar Medidor',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        backgroundColor: cs.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withValues(alpha: 0.05), cs.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e instrucciones
                  Text(
                    'Detalles de Acometida',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revise la información y actualice únicamente el número de medidor.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta de información de solo lectura
                  Card(
                    elevation: 4,
                    shadowColor: cs.shadow.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            context,
                            Icons.person,
                            'Cliente',
                            clientName,
                          ),
                          const Divider(height: 24),
                          // Cambié connectionCode por connectionCadastralKey u otro según la entidad.
                          // La entidad usa connectionAccount / connectionCadastralKey.
                          _buildInfoRow(
                            context,
                            Icons.vpn_key,
                            'Cód. Catastral',
                            conn.connectionCadastralKey,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            Icons.map,
                            'Dirección',
                            conn.connectionAddress,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            context,
                            Icons.speed,
                            'Medidor Actual',
                            (conn.connectionMeterNumber?.isEmpty ?? true)
                                ? 'Sin Medidor'
                                : conn.connectionMeterNumber!,
                            isHighlight: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nuevo Medidor',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newMeterController,
                          enabled: !_isSubmitting,
                          textInputAction: TextInputAction.next,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            labelText: 'Ingrese el nuevo número *',
                            hintText: 'Ej. 123456789',
                            suffixIcon: MicSuffixButton(
                              controller: _newMeterController,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El número de medidor es obligatorio';
                            }
                            if (value.trim() == conn.connectionMeterNumber) {
                              return 'Ingrese un número de medidor diferente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          enabled: !_isSubmitting,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Observaciones',
                            hintText: 'Ej. Motivo del cambio de medidor...',
                            alignLabelWithHint: true,
                            suffixIcon: MicSuffixButton(
                              controller: _descriptionController,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Lecturas de Medidores',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _oldMeterReadingController,
                          enabled: !_isSubmitting,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Última Lectura Medidor Anterior (Opcional)',
                            hintText: 'Ej. 120.5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newMeterInitialReadingController,
                          enabled: !_isSubmitting,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Lectura Inicial Medidor Nuevo (Opcional)',
                            hintText: 'Ej. 0.0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _newMeterCurrentReadingController,
                          enabled: !_isSubmitting,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Lectura Actual Medidor Nuevo (Opcional)',
                            hintText: 'Ej. 0.0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Photos Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Evidencia Fotográfica',
                              style: theme.textTheme.titleMedium?.copyWith(
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
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: 0.2,
                              ),
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
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.5,
                                  ),
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
                                onPressed: _images.length >= 3 || _isSubmitting
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
                                onPressed: _images.length >= 3 || _isSubmitting
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
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _submitUpdate,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              _isSubmitting
                                  ? 'Guardando...'
                                  : 'Actualizar Medidor',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? cs.tertiary : cs.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight
                      ? cs.tertiary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
