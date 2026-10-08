import 'package:flutter/material.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/utils/convert_coordinates.dart';

class ConnectionInfoCard extends StatelessWidget {
  final ConnectionWithPropertiesEntity connection;

  const ConnectionInfoCard({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clientName = connection.person != null
        ? '${connection.person!.firstName} ${connection.person!.lastName}'
        : connection.company?.businessName ?? 'Sin Cliente Asociado';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person_pin, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    clientName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.cable, color: cs.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        connection.connectionCadastralKey,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.badge_outlined,
                    'CI/RUC',
                    connection.person?.personId ??
                        connection.company?.ruc ??
                        connection.clientId,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.speed_outlined,
                    'Medidor',
                    connection.connectionMeterNumber ?? 'Sin medidor',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              'Dirección',
              connection.connectionAddress,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.info_outline,
                    'Estado',
                    connection.connectionStatus == true ? 'Activo' : 'Inactivo',
                    valueColor: connection.connectionStatus == true
                        ? cs.secondary
                        : cs.error,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.money,
                    'Tarifa',
                    connection.connectionRateName,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.north,
                    'Latitud',
                    extractCoordinates(
                          connection.connectionCoordinates ?? '',
                        )['latitude']?.toString() ??
                        'No disponible',
                    valueColor: cs.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.south,
                    'Longitud',
                    extractCoordinates(
                          connection.connectionCoordinates ?? '',
                        )['longitude']?.toString() ??
                        'No disponible',
                    valueColor: cs.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: valueColor ?? cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
