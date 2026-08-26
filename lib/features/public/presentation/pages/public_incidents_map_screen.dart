import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/components/loaders/professional_loader.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:app_properties/features/incidents/presentation/widgets/incident_detail_sheet.dart';
import 'package:app_properties/features/public/presentation/cubit/public_incidents_map_cubit.dart';
import 'package:app_properties/features/public/presentation/cubit/public_incidents_map_state.dart';
import 'package:app_properties/features/public/presentation/widgets/animated_heartbeat_marker.dart';

class PublicIncidentsMapScreen extends StatefulWidget {
  const PublicIncidentsMapScreen({super.key});

  @override
  State<PublicIncidentsMapScreen> createState() =>
      _PublicIncidentsMapScreenState();
}

class _PublicIncidentsMapScreenState extends State<PublicIncidentsMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Coordenadas centrales de Antonio Ante (referencia)
  final LatLng _centerLatLng = const LatLng(0.3344, -78.2144);

  String _selectedStatus = 'TODOS';
  int? _selectedSector;
  String _searchQuery = '';
  bool _isListVisible = false;
  String? _selectedIncidentCode;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocBuilder<PublicIncidentsMapCubit, PublicIncidentsMapState>(
        builder: (context, state) {
          if (state is PublicIncidentsMapLoading) {
            return const ProfessionalLoader(
              label: 'Cargando...',
              description: 'Se está cargando la información',
            );
          }

          if (state is PublicIncidentsMapError) {
            return _buildErrorState(context, colors, state.message);
          }

          if (state is PublicIncidentsMapLoaded) {
            return _buildMapArea(context, colors, state.incidents);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMapArea(
    BuildContext context,
    ColorScheme colors,
    List<IncidentDetailRowResponse> incidents,
  ) {
    // Filtrar incidentes por estado y búsqueda
    final filteredIncidents = incidents.where((i) {
      final matchesStatus =
          _selectedStatus == 'TODOS' ||
          i.status.toUpperCase() == _selectedStatus;

      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          i.incidentCode.toLowerCase().contains(query) ||
          (i.connectionId?.toLowerCase().contains(query) ?? false) ||
          i.categoryName.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();

    return Stack(
      children: [
        _buildMap(context, colors, filteredIncidents),
        // Top Floating Search and Filter Bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 5,
          left: 5,
          right: 5,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4.0,
                    right: 8.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: colors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      Icon(Icons.search, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar por código, acometida...',
                            hintStyle: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: colors.onSurface.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                    ],
                  ),
                ),
                // Sector Filter
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Sector:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedSector,
                            hint: Text(
                              'Todos los sectores',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface,
                              ),
                            ),
                            isDense: true,
                            isExpanded: true,
                            iconSize: 20,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(
                                  'Todos los sectores',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ),
                              ...List.generate(40, (index) {
                                final sectorNumber = index + 1;
                                return DropdownMenuItem<int>(
                                  value: sectorNumber,
                                  child: Text(
                                    'Sector $sectorNumber',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedSector = val;
                              });
                              context
                                  .read<PublicIncidentsMapCubit>()
                                  .loadMapIncidents(sector: val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.onSurface.withValues(alpha: 0.1),
                ),
                // Filter Chips
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      _buildFilterChip('TODOS', colors),
                      _buildFilterChip('REPORTADO', colors),
                      _buildFilterChip('EN_PROCESO', colors),
                      _buildFilterChip('RESUELTO', colors),
                    ],
                  ),
                ),

                //Listar los filtrados
                _buildIncidentList(context, colors, filteredIncidents),
              ],
            ),
          ),
        ),
        // Map Controls
        Positioned(
          right: 16,
          bottom: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'center_btn',
                mini: true,
                backgroundColor: colors.surface.withValues(alpha: 0.9),
                onPressed: () {
                  _mapController.move(_centerLatLng, 14.0);
                },
                child: Icon(Icons.my_location, color: colors.primary),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_in_btn',
                mini: true,
                backgroundColor: colors.surface.withValues(alpha: 0.9),
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
                child: Icon(Icons.add, color: colors.onSurface),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out_btn',
                mini: true,
                backgroundColor: colors.surface.withValues(alpha: 0.9),
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
                child: Icon(Icons.remove, color: colors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, ColorScheme colors) {
    final isSelected = _selectedStatus == label;
    final color = label == 'TODOS' ? colors.primary : _getStatusColor(label);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label.replaceAll('_', ' ')),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        backgroundColor: colors.surface.withValues(alpha: 0.9),
        selectedColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.transparent : color),
        ),
        onSelected: (bool selected) {
          setState(() {
            _selectedStatus = label;
          });
        },
      ),
    );
  }

  Widget _buildIncidentList(
    BuildContext context,
    ColorScheme colors,
    List<IncidentDetailRowResponse> incidents,
  ) {
    if (incidents.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incidencias (${incidents.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isListVisible ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: () {
                  setState(() {
                    _isListVisible = !_isListVisible;
                  });
                },
              ),
            ],
          ),
          if (_isListVisible) const SizedBox(height: 16),
          if (_isListVisible)
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final incident = incidents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIncidentCode = incident.incidentCode;
                        });
                        if (incident.latitude != null &&
                            incident.longitude != null) {
                          _mapController.move(
                            LatLng(
                              incident.latitude! + 0.0050,
                              incident.longitude!,
                            ),
                            16.0,
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(
                              incident.status,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(incident.categoryCode),
                              color: _getStatusColor(incident.status),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    incident.incidentCode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                  Text(
                                    incident.categoryName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${incident.reportDate.day}/${incident.reportDate.month}/${incident.reportDate.year}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Sector Name View
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cable,
                                        size: 12,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Clave Catastral: ${incident.connectionId}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 12,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Sector: ${incident.connectionId != null ? incident.connectionId!.split('-')[0] : 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    ColorScheme colors,
    List<IncidentDetailRowResponse> incidents,
  ) {
    final unselectedMarkers = <Marker>[];
    Marker? selectedMarker;

    for (final incident in incidents) {
      final isSelected = _selectedIncidentCode == incident.incidentCode;

      final marker = Marker(
        point: LatLng(incident.latitude!, incident.longitude!),
        width: isSelected ? 140 : 50,
        height: isSelected ? 85 : 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedIncidentCode = incident.incidentCode;
            });
            _showIncidentDetails(context, colors, incident);
          },
          child: isSelected
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        incident.incidentCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedHeartbeatMarker(
                      color: Colors.blueAccent,
                      icon: Icons.location_on_rounded,
                      size: 36,
                    ),
                  ],
                )
              : AnimatedHeartbeatMarker(
                  color: _getStatusColor(incident.status),
                  icon: _getCategoryIcon(incident.categoryCode),
                  size: 24,
                ),
        ),
      );

      if (isSelected) {
        selectedMarker = marker;
      } else {
        unselectedMarkers.add(marker);
      }
    }

    final markers = [
      ...unselectedMarkers,
      if (selectedMarker != null) selectedMarker,
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileUrl = isDark
        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _centerLatLng,
        initialZoom: 14.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(urlTemplate: tileUrl, userAgentPackageName: 'com.epaa.app'),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ColorScheme colors,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar el mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PublicIncidentsMapCubit>().loadMapIncidents(
                  sector: _selectedSector,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncidentDetails(
    BuildContext context,
    ColorScheme colors,
    IncidentDetailRowResponse incident,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return IncidentDetailSheet(
          incident: incident,
          statusColor: _getStatusColor(incident.status),
          statusLabel: _getStatusLabel(incident.status),
          priorityColor: _getPriorityColor(incident.currentPriority),
          getImageUrl: _getImageUrl,
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _selectedIncidentCode = null;
        });
      }
    });
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'REPORTADO':
        return 'Reportado';
      case 'EN_INSPECCION':
        return 'En Inspección';
      case 'RESUELTO':
        return 'Resuelto';
      case 'FALSO_REPORTE':
        return 'Falso Reporte';
      default:
        return status;
    }
  }

  String _getImageUrl(String filePath) {
    if (filePath.isEmpty) return '';
    if (filePath.startsWith('http')) return filePath;
    final base = Environment.apiUrl.endsWith('/')
        ? Environment.apiUrl.substring(0, Environment.apiUrl.length - 1)
        : Environment.apiUrl;
    final relative = filePath.startsWith('/') ? filePath : '/$filePath';
    return '$base$relative';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return Colors.redAccent;
      case 'MEDIA':
        return Colors.orangeAccent;
      case 'BAJA':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'REPORTADO':
        return Colors.orange;
      case 'ASIGNADO':
        return Colors.blue;
      case 'EN_PROCESO':
        return Colors.orangeAccent;
      case 'RESUELTO':
        return Colors.green;
      case 'ANULADO':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String categoryCode) {
    switch (categoryCode.toUpperCase()) {
      case 'FUGAS-AGUA':
        return Icons.water_damage_rounded;

      case 'INFRAESTRUCTURA-REPOSICION':
        return Icons.construction_rounded;

      case 'DAÑO-INFRAESTRUCTURA':
        return Icons.report_gmailerrorred_rounded;

      case 'FRAUDE-IRREGULARIDADES':
        return Icons.gpp_bad_rounded;

      case 'ANOMALIA-CONSUMO':
        return Icons.analytics_rounded;

      case '  RED-MATRIZ':
        return Icons.timeline_rounded;

      case 'ALCANTARILLADO-REBALSE':
        return Icons.public;

      default:
        return Icons.report_problem_rounded;
    }
  }
}
