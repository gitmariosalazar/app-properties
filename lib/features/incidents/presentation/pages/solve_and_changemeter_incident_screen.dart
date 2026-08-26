// lib/features/incidents/presentation/pages/solve_incident_screen.dart
import 'dart:io';

import 'package:app_properties/features/properties/search/data/mappers/connection_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_state.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/change_meter_usecase.dart';
import 'package:app_properties/features/properties/form/update/data/models/dto/request/change_meter_request.dart' as cmr;
import 'package:app_properties/components/button/widget_button.dart';
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_datasource.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/core/di/injection.dart' as di;

class SolveAndChangeMeterIncidentScreen extends StatefulWidget {
  final String incidentId;
  final String incidentCode;
  final String? connectionId;

  const SolveAndChangeMeterIncidentScreen({
    super.key,
    required this.incidentId,
    required this.incidentCode,
    this.connectionId,
  });

  @override
  State<SolveAndChangeMeterIncidentScreen> createState() =>
      _SolveAndChangeMeterIncidentScreenState();
}

class _SolveAndChangeMeterIncidentScreenState
    extends State<SolveAndChangeMeterIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _numeroMedidorController = TextEditingController();
  final _claveCatastralController = TextEditingController();
  final _oldMeterReadingController = TextEditingController();
  final _newMeterInitialReadingController = TextEditingController();
  final _newMeterCurrentReadingController = TextEditingController();

  List<File> _images = [];

  bool _isLoadingConnection = false;
  bool _isUpdating = false;
  ConnectionEntity? _connection;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.connectionId != null && widget.connectionId!.isNotEmpty) {
      _claveCatastralController.text = widget.connectionId!;
      _fetchConnectionInfo();
    }
  }

  Future<void> _fetchConnectionInfo() async {
    setState(() {
      _isLoadingConnection = true;
    });
    try {
      final dataSource = di.sl<RemoteConnectionDataSource>();
      final responses = await dataSource
          .getConnectionByCadastralKeyOrClientIdOrCardId(widget.connectionId!);
      if (responses.isNotEmpty) {
        setState(() {
          _connection = responses.first.toEntity();
        });
      }
    } catch (_) {
      // Si falla, simplemente no mostramos el resumen.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingConnection = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _numeroMedidorController.dispose();
    _claveCatastralController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loginState = context.read<LoginCubit>().state;
    if (loginState is! LoginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró sesión activa.')),
      );
      return;
    }

    final resolverUserId = loginState.user.id;

    final validImages = _images.where((file) => file.existsSync()).toList();

    final changeDetailsList = <IncidentChangeDetail>[];

    final numeroMedidor = _numeroMedidorController.text.trim();
    final claveCatastral = _claveCatastralController.text.trim();

    if (numeroMedidor.isNotEmpty || claveCatastral.isNotEmpty) {
      changeDetailsList.add(
        IncidentChangeDetail(
          numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
          claveCatastral: claveCatastral.isNotEmpty ? claveCatastral : null,
          observaciones: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() 
              : null,
          medidorAnterior: OldMeterData(
            numeroMedidor: _connection?.connectionMeterNumber,
            ultimaLectura: double.tryParse(_oldMeterReadingController.text.trim()),
            fechaUltimaLectura: DateTime.now().toIso8601String(),
          ),
          medidorNuevo: NewMeterData(
            numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
            lecturaAnterior: double.tryParse(_newMeterInitialReadingController.text.trim()),
            lecturaActual: double.tryParse(_newMeterCurrentReadingController.text.trim()),
            fechaUltimaLectura: DateTime.now().toIso8601String(),
          ),
        ),
      );
    }

    // UPDATE CONNECTION IF NEEDED
    if (numeroMedidor.isNotEmpty) {
      if (_connection == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Espere, cargando información de la acometida...'),
          ),
        );
        return;
      }

      final currentConn = _connection!;
      if (currentConn.connectionMeterNumber != numeroMedidor) {
        setState(() => _isUpdating = true);
        try {
          final meterDetail = cmr.MeterChangeDetail(
            numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
            claveCatastral: claveCatastral.isNotEmpty ? claveCatastral : null,
            observaciones: _descriptionController.text.trim().isNotEmpty 
                ? _descriptionController.text.trim() 
                : null,
            medidorAnterior: cmr.OldMeterData(
              numeroMedidor: currentConn.connectionMeterNumber,
              ultimaLectura: double.tryParse(_oldMeterReadingController.text.trim()),
              fechaUltimaLectura: DateTime.now().toIso8601String(),
            ),
            medidorNuevo: cmr.NewMeterData(
              numeroMedidor: numeroMedidor.isNotEmpty ? numeroMedidor : null,
              lecturaAnterior: double.tryParse(_newMeterInitialReadingController.text.trim()),
              lecturaActual: double.tryParse(_newMeterCurrentReadingController.text.trim()),
              fechaUltimaLectura: DateTime.now().toIso8601String(),
            ),
          );

          final changeMeterReq = cmr.ChangeMeterRequest(
            connectionId: currentConn.connectionId,
            changeDetail: meterDetail,
            images: validImages,
            imageDescriptions: [], // Sin descripciones específicas por ahora
          );

          await di.sl<ChangeMeterUseCase>()(changeMeterReq);

          // Limpiar la lista para evitar que el endpoint de resolver incidente vuelva a registrar el cambio
          changeDetailsList.clear();
        } catch (e) {
          setState(() => _isUpdating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar acometida: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Stop here if it fails
        }
        setState(() => _isUpdating = false);
      }
    }

    final request = ResolveIncidentRequest(
      description: _descriptionController.text.trim(),
      repairCost: 0.0,
      chargeToUser: false,
      images: validImages,
      changeDetails: changeDetailsList.isNotEmpty ? changeDetailsList : null,
    );

    if (mounted) {
      context.read<IncidentCubit>().resolveIncident(
        incidentId: widget.incidentId,
        resolverUserId: resolverUserId,
        request: request,
      );
    }
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

          final claveCatastral = _claveCatastralController.text.trim();
          if (claveCatastral.isNotEmpty) {
            context.push('/detail-page', extra: claveCatastral);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incidencia resuelta. No hay clave catastral para mostrar el detalle.'),
                backgroundColor: Colors.orange,
              ),
            );
            context.pop(true);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is IncidentLoading || _isUpdating;

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

                  // Resumen de Acometida
                  if (_isLoadingConnection)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_connection != null) ...[
                    _buildConnectionSummary(context, cs),
                    const SizedBox(height: 24),
                  ],

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
                  const SizedBox(height: 32),

                  // Nuevos Datos del Medidor / Acometida
                  Text(
                    'Datos de Actualización de Acometida',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revise la clave catastral y complete el número de medidor si aplica.',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _claveCatastralController,
                    decoration: InputDecoration(
                      labelText: 'Clave Catastral (Acometida)',
                      hintText: 'Ej. 170101010101',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _numeroMedidorController,
                    decoration: InputDecoration(
                      labelText: 'Nuevo Número de Medidor',
                      hintText: 'Ej. 0987654321',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Lecturas de Medidores',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _oldMeterReadingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Última Lectura Medidor Anterior (Opcional)',
                      hintText: 'Ej. 120.5',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _newMeterInitialReadingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Lectura Inicial Medidor Nuevo (Opcional)',
                      hintText: 'Ej. 0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _newMeterCurrentReadingController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Lectura Actual Medidor Nuevo (Opcional)',
                      hintText: 'Ej. 0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withOpacity(0.2),
                    ),
                  ),

                  const SizedBox(height: 32),

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

  Widget _buildConnectionSummary(BuildContext context, ColorScheme cs) {
    final conn = _connection!;
    String ownerName = 'Sin Nombre';
    String ownerDoc = 'N/A';
    bool isNatural = conn.person != null;

    if (isNatural) {
      ownerName =
          '${conn.person!.firstName ?? ''} ${conn.person!.lastName ?? ''}'
              .trim();
      ownerDoc = conn.clientId;
    } else if (conn.company != null) {
      ownerName =
          conn.company!.businessName ??
          conn.company!.commercialName ??
          'Empresa Registrada';
      ownerDoc = conn.company!.ruc;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Información Actual de la Acometida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(),
          _buildSummaryRow('Propietario', ownerName),
          _buildSummaryRow('Identificación', ownerDoc),
          _buildSummaryRow('Clave Catastral', conn.connectionCadastralKey),
          _buildSummaryRow(
            'Medidor Actual',
            conn.connectionMeterNumber ?? 'Sin Medidor',
          ),
          _buildSummaryRow(
            'Estado',
            conn.connectionStateId == 1 ? 'Activa' : 'Inactiva',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
