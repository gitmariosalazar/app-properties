// lib/features/incidents/presentation/widgets/incident_card.dart
import 'package:app_properties/components/button/widget_button.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/properties/search/domain/services/map_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class IncidentCard extends StatelessWidget {
  final IncidentDetailRowResponse incident;
  final VoidCallback onTap;
  final Color statusColor;
  final String statusLabel;
  final Color priorityColor;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    required this.statusColor,
    required this.statusLabel,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Category & Priority
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconIncidentType(
                            categoryCode: incident.categoryCode ?? 'OTRO',
                            incidentType: incident.incidentTypeId.toString(),
                            color: cs.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              incident.categoryName ?? 'Incidencia',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: priorityColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  incident.suggestedPriority.toUpperCase(),
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'Nº: ${incident.incidentCode}',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Incident Title/Type
                Text(
                  incident.incidentTypeName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description snippet
                Text(
                  incident.reportDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                Divider(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Footer Info: connectionId, Date & Status badge
                Row(
                  children: [
                    Icon(
                      incident.connectionId != null
                          ? Icons.cable_outlined
                          : Icons.electrical_services,
                      size: 14,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      incident.connectionId != null
                          ? 'Acometida: ${incident.connectionId}'
                          : 'Matriz Principal',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sector: ${incident.connectionId!.split('-')[0]}',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date and Origin row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(incident.reportDate),
                      style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'Origen: ${incident.reportOrigin}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  spacing: 8,
                  children: [
                    if (incident.status != 'RESUELTO')
                      Expanded(
                        child: ActionButton(
                          onPressed: () async {
                            final result = await context.push(
                              '/solve-and-change-meter',
                              extra: {
                                'incidentId': incident.incidentId,
                                'incidentCode': incident.incidentCode,
                                'connectionId': incident.connectionId,
                              },
                            );
                            if (result == true && context.mounted) {
                              // Do nothing, list should probably refresh, but we shouldn't pop the whole page.
                            }
                          },
                          icon: Icons.water_damage_outlined,
                          label: 'Cambiar medidor',
                          color: AppColors.primary,
                          size: ActionButtonSize.small,
                          disabled: incident.status == 'RESUELTO',
                          hideElevation: incident.status == 'RESUELTO',
                        ),
                      ),
                    /*
                    if (incident.status != 'RESUELTO')
                      Expanded(
                        child: ActionButton(
                          onPressed: () async {
                            final result = await context.push(
                              '/solve-and-change-meter',
                              extra: {
                                'incidentId': incident.incidentId,
                                'incidentCode': incident.incidentCode,
                                'connectionId': incident.connectionId,
                              },
                            );
                            if (result == true && context.mounted) {
                              // Do nothing, list should probably refresh, but we shouldn't pop the whole page.
                            }
                          },
                          icon: Icons.assignment_outlined,
                          label: 'Gestionar',
                          color: AppColors.primary,
                          size: ActionButtonSize.small,
                          disabled: incident.status == 'RESUELTO',
                          hideElevation: incident.status == 'RESUELTO',
                        ),
                      ),
                      */
                    if (incident.latitude != null && incident.longitude != null)
                      Expanded(
                        child: ActionButton(
                          onPressed: () async {
                            final mapService = di.sl<MapNavigationService>();
                            try {
                              await mapService.navigateTo(
                                incident.latitude!,
                                incident.longitude!,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                    ),
                                    backgroundColor: cs.error,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icons.location_on_rounded,
                          label: 'Cómo llegar',
                          color: AppColors.secondary,
                          size: ActionButtonSize.small,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconIncidentType extends StatelessWidget {
  final String categoryCode;
  final String incidentType;
  final Color? color;
  final double? size;

  const IconIncidentType({
    super.key,
    required this.categoryCode,
    required this.incidentType,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    IconData getIconData() {
      switch (categoryCode) {
        case 'FUGAS':
          // Fugas (Gotas, llaves goteando, agua escapando)
          return Icons.water_drop_outlined;

        case 'INFRAESTRUCTURA':
          // Infraestructura (La caja del medidor, la tapa, cemento, la estructura física)
          return Icons.add_box_outlined;
        // Una opción excelente y muy limpia es:
        // return Icons.build_circle_outlined; // Representa mantenimiento/infraestructura

        case 'DAÑOS Y PERJUICIOS':
          // Daños y Pérdidas (Medidor roto, destruido, vandalismo)
          return Icons.report_problem_outlined;

        case 'FRAUDE':
          // Fraudes e Irregularidades (Medidor invertido, bypass, robo de agua)
          // Usamos el ícono de "alerta de fraude/candado abierto/ojo espía"
          return Icons.gavel_outlined;

        case 'CONSUMO':
          // Anomalías de Consumo (Saltos drásticos de consumo, medidor frenado)
          // Idealmente un ícono que represente gráficos o medidores analógicos
          return Icons.speed_outlined;

        case 'RED MATRIZ':
          // Red Matriz y Vía Pública (Tuberías principales en la calle)
          return Icons.waves_outlined;

        case 'ALCANTARILLADO':
          // Alcantarillado (Sumideros, pozos de revisión, aguas servidas)
          // Un ícono que simule rejillas o desagüe
          return Icons.opacity_outlined;

        case 'OTRO':
          // Otro (Casos imprevistos)
          return Icons.help_outline_rounded;
        default:
          switch (incidentType) {
            case '1':
              return Icons.electrical_services_outlined;
            case '2':
              return Icons.water_outlined;
            case '3':
              return Icons.plumbing;
            default:
              return Icons.electrical_services_outlined;
          }
      }
    }

    return Icon(getIconData(), color: color, size: size);
  }
}
