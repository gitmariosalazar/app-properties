import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/components/widgets/mic_suffix_button.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:app_properties/utils/convert_coordinates.dart';

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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newMeterController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final useCase = di.sl<UpdateConnectionUseCase>();

      final coords = extractCoordinates(widget.connection.connectionCoordinates ?? '');
      final lat = coords['latitude'] ?? 0.0;
      final lng = coords['longitude'] ?? 0.0;

      // Construir el objeto UpdateConnectionParams preservando toda la información existente,
      // pero actualizando exclusivamente el número del medidor.
      final params = UpdateConnectionParams(
        clientId: widget.connection.clientId,
        connectionRateId: widget.connection.connectionRateId,
        connectionRateName: widget.connection.connectionRateName,
        connectionMeterNumber: _newMeterController.text.trim(),
        connectionContractNumber: widget.connection.connectionContractNumber,
        connectionSewerage: widget.connection.connectionSewerage,
        connectionStatus: widget.connection.connectionStatus,
        connectionAddress: widget.connection.connectionAddress,
        connectionInstallationDate:
            widget.connection.connectionInstallationDate,
        connectionPeopleNumber: widget.connection.connectionPeopleNumber,
        connectionZone: widget.connection.connectionZone,
        longitude: lng,
        latitude: lat,
        connectionReference: widget.connection.connectionReference,
        connectionMetaData: widget.connection.connectionMetadata,
        connectionAltitude: widget.connection.connectionAltitude,
        connectionPrecision: widget.connection.connectionPrecision,
        connectionGeolocationDate: widget.connection.connectionGeolocationDate
            ?.toIso8601String(),
        connectionGeometricZone: widget.connection.connectionGeometricZone,
        propertyCadastralKey: widget.connection.propertyCadastralKey,
        zoneId: widget.connection.zoneId ?? 0,
      );

      await useCase.call(
        connectionId: widget.connection.connectionId,
        params: params,
      );

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
                          textInputAction: TextInputAction.done,
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
                        const SizedBox(height: 32),
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
