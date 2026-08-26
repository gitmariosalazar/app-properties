import 'package:app_properties/components/button/widget_button.dart';
import 'package:app_properties/components/chip/color_chip.dart';
import 'package:app_properties/components/empty/EmptyData.dart';
import 'package:app_properties/components/photo/photo_grid.dart';
import 'package:app_properties/core/theme/app_colors.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class IncidentDetailSheet extends ConsumerStatefulWidget {
  final IncidentDetailRowResponse incident;
  final Color statusColor;
  final String statusLabel;
  final Color priorityColor;
  final String Function(String) getImageUrl;
  final VoidCallback? onIncidentResolved;

  const IncidentDetailSheet({
    super.key,
    required this.incident,
    required this.statusColor,
    required this.statusLabel,
    required this.priorityColor,
    required this.getImageUrl,
    this.onIncidentResolved,
  });

  @override
  ConsumerState<IncidentDetailSheet> createState() =>
      _IncidentDetailSheetState();
}

class _IncidentDetailSheetState extends ConsumerState<IncidentDetailSheet> {
  String? _country;
  String? _province;
  String? _canton;
  String? _fullAddress;
  bool _isLoadingAddress = false;
  String? _errorGeocoding;

  @override
  void initState() {
    super.initState();
    _loadLocationDetails();
  }

  void _loadLocationDetails() {
    if (widget.incident.latitude != null && widget.incident.longitude != null) {
      _performReverseGeocoding(
        widget.incident.latitude!,
        widget.incident.longitude!,
      );
    }
  }

  Future<void> _performReverseGeocoding(double lat, double lng) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      _errorGeocoding = null;
    });

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _country = place.country ?? 'Ecuador';
          _province = place.administrativeArea ?? '';
          _canton = place.subAdministrativeArea ?? place.locality ?? '';
          _fullAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _errorGeocoding = 'No se encontraron detalles de la dirección.';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorGeocoding = 'Error al extraer la dirección real.';
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    if (widget.incident.latitude == null || widget.incident.longitude == null) {
      return;
    }
    final lat = widget.incident.latitude!;
    final lng = widget.incident.longitude!;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'REPORTADO':
        return const Color(0xFFE65100);
      case 'EN_INSPECCION':
        return Colors.deepPurpleAccent;
      case 'RESUELTO':
        return const Color(0xFF2E7D32);
      case 'FALSO_REPORTE':
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHigh : cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 16),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles del Incidente',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nº: ${widget.incident.incidentCode} · Clave Catastral: ${widget.incident.connectionId ?? "N/A"}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (widget.incident.status != 'RESUELTO')
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      onPressed: () async {
                        final result = await context.push(
                          '/solve-incident',
                          extra: {
                            'incidentId': widget.incident.incidentId,
                            'incidentCode': widget.incident.incidentCode,
                          },
                        );
                        if (result == true && context.mounted) {
                          context.pop(); // Close the bottom sheet
                          widget.onIncidentResolved?.call();
                        }
                      },
                      icon: Icons.add_task,
                      label: 'Resolver',
                      color: AppColors.primary,
                      size: ActionButtonSize.small,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      onPressed: () async {
                        final result = await context.push(
                          '/solve-and-change-meter',
                          extra: {
                            'incidentId': widget.incident.incidentId,
                            'incidentCode': widget.incident.incidentCode,
                            'connectionId': widget.incident.connectionId,
                          },
                        );
                        if (result == true && context.mounted) {
                          context.pop(); // Close the bottom sheet
                          widget.onIncidentResolved?.call();
                        }
                      },
                      icon: Icons.water_damage_outlined,
                      label: 'Cambiar medidor',
                      color: AppColors.primary,
                      size: ActionButtonSize.small,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges (Status, Priority, Origin)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.statusLabel,
                          style: TextStyle(
                            color: widget.statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: widget.priorityColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Prioridad: ${widget.incident.suggestedPriority}',
                          style: TextStyle(
                            color: widget.priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category & Type
                  _buildSectionTitle(context, 'CATEGORÍA Y TIPO'),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    context,
                    icon: Icons.category_rounded,
                    title: widget.incident.categoryName ?? 'Sin categoría',
                    subtitle:
                        widget.incident.incidentTypeName ??
                        'Sin tipo de incidente',
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildSectionTitle(context, 'DESCRIPCIÓN'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      widget.incident.reportDescription,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reference Address
                  if (widget.incident.referenceAddress != null &&
                      widget.incident.referenceAddress!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'DIRECCIÓN DE REFERENCIA'),
                    const SizedBox(height: 8),
                    _buildInfoTile(
                      context,
                      icon: Icons.location_on_rounded,
                      title: widget.incident.referenceAddress!,
                      subtitle: 'Dirección ingresada por el lecturista',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // GPS Coordinates Map view
                  if (widget.incident.latitude != null &&
                      widget.incident.longitude != null) ...[
                    _buildSectionTitle(context, 'GEOLOCALIZACIÓN (GPS)'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_searching_rounded,
                                color: cs.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Coordenadas de Reporte',
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Lat: ${widget.incident.latitude!.toStringAsFixed(8)} · Lng: ${widget.incident.longitude!.toStringAsFixed(8)}',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.navigation_rounded,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Abrir Mapa',
                                  style: TextStyle(fontSize: 11),
                                ),
                                onPressed: _openGoogleMaps,
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 0.8),
                          // Address loading or content
                          if (_isLoadingAddress)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Extrayendo dirección real...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_errorGeocoding != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: cs.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorGeocoding!,
                                    style: TextStyle(
                                      color: cs.error,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _loadLocationDetails,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'Reintentar',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildGeocodeDetailRow(
                              context,
                              icon: Icons.flag_rounded,
                              label: 'País',
                              value: _country ?? 'Ecuador',
                            ),
                            const SizedBox(height: 8),
                            _buildGeocodeDetailRow(
                              context,
                              icon: Icons.map_rounded,
                              label: 'Provincia',
                              value: _province ?? 'Imbabura',
                            ),
                            const SizedBox(height: 8),
                            _buildGeocodeDetailRow(
                              context,
                              icon: Icons.location_city_rounded,
                              label: 'Cantón',
                              value: _canton ?? '',
                            ),
                            const SizedBox(height: 8),
                            _buildGeocodeDetailRow(
                              context,
                              icon: Icons.home_rounded,
                              label: 'Dirección Real Extraída',
                              value: _fullAddress ?? 'Sin dirección disponible',
                              isMultiline: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Photos of evidence
                  if (widget.incident.photosReport.isNotEmpty) ...[
                    _buildSectionTitle(
                      context,
                      'FOTOS DEL REPORTE - EVIDENCIA',
                    ),
                    const SizedBox(height: 8),

                    PhotoGallery(
                      imagePaths: widget.incident.photosReport
                          .map((p) => p.filePath)
                          .toList(),
                      title: 'Fotos del Reporte',
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildSectionTitle(
                      context,
                      'FOTOS DEL REPORTE - EVIDENCIA',
                    ),
                    // 4. Con icono personalizado
                    EmptyState(
                      icon: Icons.camera_alt_rounded,
                      iconColor: Colors.orange,
                      title: 'No hay evidencias',
                      iconSize: 25,
                      description:
                          'El usuario no adjuntó evidencias fotográficas.',
                    ),
                  ],

                  // Photos of evidence
                  if (widget.incident.photosResolution.isNotEmpty) ...[
                    _buildSectionTitle(
                      context,
                      'FOTOS DE LA RESOLUCIÓN - EVIDENCIA',
                    ),
                    const SizedBox(height: 8),
                    PhotoGallery(
                      imagePaths: widget.incident.photosResolution
                          .map((p) => p.filePath)
                          .toList(),
                      title: 'Fotos de Resolución',
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildSectionTitle(
                      context,
                      'FOTOS DE LA RESOLUCIÓN - EVIDENCIA',
                    ),
                    EmptyState(
                      icon: Icons.camera_alt_rounded,
                      iconColor: Colors.orange,
                      title: 'No hay fotos',
                      iconSize: 25,
                      description:
                          'El usuario no adjuntó fotos como evidencia del reporte.',
                    ),
                  ],

                  // Resolution details
                  if (widget.incident.status.toUpperCase() == 'RESUELTO' &&
                      widget.incident.resolutionDate != null) ...[
                    _buildSectionTitle(context, 'DETALLES DE RESOLUCIÓN'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(
                            0xFF2E7D32,
                          ).withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF2E7D32),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Resuelto exitosamente',
                                style: TextStyle(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (widget.incident.resolutionDate != null)
                            _buildResolutionRow(
                              context,
                              'Fecha de resolución:',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(widget.incident.resolutionDate!),
                            ),
                          if (widget.incident.resolvedBy != null)
                            _buildResolutionRow(
                              context,
                              'Resuelto por:',
                              widget.incident.resolvedBy!.name,
                            ),
                          if (widget.incident.resolutionDescription != null &&
                              widget.incident.resolutionDescription!.isNotEmpty)
                            _buildResolutionRow(
                              context,
                              'Detalle técnico:',
                              widget.incident.resolutionDescription!,
                            ),
                          _buildResolutionRow(
                            context,
                            'Costo de reparación:',
                            '\$${widget.incident.repairCost.toStringAsFixed(2)}',
                          ),
                          _buildResolutionRow(
                            context,
                            'Cobrar al usuario:',
                            widget.incident.chargeToUser
                                ? 'SÍ (Afecta a factura)'
                                : 'NO (Asumido por EPAA)',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Change History Timeline
                  if (widget.incident.historyRecent.isNotEmpty) ...[
                    _buildSectionTitle(
                      context,
                      'HISTORIAL DE CAMBIOS DE ESTADO',
                    ),
                    const SizedBox(height: 10),
                    ...widget.incident.historyRecent.map((history) {
                      final dateStr = DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(history.dateChange);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            border: Border.all(color: cs.outlineVariant),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(history.newStatus),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 75,
                                    color: cs.outlineVariant,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          history.newStatus,
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (history.observation != null &&
                                        history.observation!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        width: double.infinity,

                                        decoration: BoxDecoration(
                                          color: cs.outlineVariant,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                '${history.observation}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: cs.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (history.managedBy != null)
                                      Row(
                                        children: [
                                          ColorChip(
                                            label:
                                                '${history.managedBy?.nombre} ${history.managedBy?.apellido}',
                                            variant: ColorChipVariant.ghost,
                                            size: ColorChipSize.sm,
                                            withDot: false,
                                            icon: const Icon(
                                              Icons.person_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                    Row(
                                      children: [
                                        if (history
                                                .managedBy
                                                ?.correo
                                                ?.isNotEmpty ??
                                            false) ...[
                                          ColorChip(
                                            label: history.managedBy!.correo!,
                                            color: Colors.indigo,
                                            variant: ColorChipVariant.ghost,
                                            size: ColorChipSize.sm,
                                            icon: const Icon(
                                              Icons.mail_outline,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        if (history
                                                .managedBy
                                                ?.celular
                                                ?.isNotEmpty ??
                                            false) ...[
                                          ColorChip(
                                            label: history.managedBy!.celular!,
                                            color: Colors.indigo,
                                            variant: ColorChipVariant.ghost,
                                            size: ColorChipSize.sm,
                                            icon: const Icon(
                                              Icons.phone_outlined,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeocodeDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: cs.onSurfaceVariant.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: cs.onSurface, fontSize: 11),
            maxLines: isMultiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: cs.onSurface, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
