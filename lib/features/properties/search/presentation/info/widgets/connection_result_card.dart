import 'package:app_properties/components/badge/custom_badge.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/services/document_export_service.dart';
import 'connection_details_sheet.dart';

class ConnectionResultCard extends StatelessWidget {
  final ConnectionEntity connection;
  final VoidCallback onTap;

  const ConnectionResultCard({
    super.key,
    required this.connection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cardRadius = context.mediumBorderRadiusValue;

    // Get client name
    String clientName = 'Sin Propietario';
    if (connection.person != null) {
      final p = connection.person!;
      clientName = '${p.firstName ?? ''} ${p.lastName ?? ''}'.trim();
    } else if (connection.company != null) {
      final c = connection.company!;
      clientName = c.businessName ?? c.commercialName ?? 'Compañía';
    }

    return Card(
      elevation: 3,
      shadowColor: cs.shadow.withValues(alpha: 0.05),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER: ID + STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          color: cs.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Acometida ID: ${connection.connectionId}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomBadge(
                      label: connection.connectionStateId == 1
                          ? 'Activo'
                          : 'Inactivo',
                      theme: connection.connectionStateId == 1
                          ? BadgeColorTheme.success
                          : BadgeColorTheme.danger,
                      size: BadgeSize.small,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),

              // INFO GRID/COLUMN
              _buildInfoRow(
                theme,
                Icons.person_rounded,
                'Propietario:',
                clientName,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.vpn_key_rounded,
                'Clave Catastral:',
                connection.connectionCadastralKey,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.speed_rounded,
                'Nº Medidor:',
                connection.connectionMeterNumber ?? 'Sin Medidor',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.location_on_rounded,
                'Dirección:',
                connection.connectionAddress.isEmpty
                    ? 'Sin dirección registrada'
                    : connection.connectionAddress,
              ),

              if (connection.zoneName != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.grid_view_rounded,
                  'Zona:',
                  connection.zoneName!,
                ),
              ] else ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.grid_view_rounded,
                  'Zona:',
                  'Sin zona',
                ),
              ],
              if (connection.property != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  theme,
                  Icons.map_rounded,
                  'Predio ID:',
                  connection.property!.propertyCadastralKey,
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.map_rounded,
                      color: theme.hintColor.withValues(alpha: 0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Predio ID:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.hintColor.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomBadge(
                          label: 'Sin referencia a una propiedad',
                          theme: BadgeColorTheme.danger,
                          size: BadgeSize.small,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              // Actions (Edit and View Details, Export to PDF)
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary.withValues(alpha: 0.1),
                        foregroundColor: cs.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.black.withValues(alpha: 0.5),
                          builder: (context) =>
                              ConnectionDetailsSheet(connection: connection),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Ver Detalles'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final exportService = di.sl<DocumentExportService>();
                          await exportService.exportConnectionActa(connection);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al exportar acta: $e'),
                                backgroundColor: Colors.red.shade800,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Acta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.hintColor.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.hintColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
