// lib/features/incidents/presentation/page/incident_history_page.dart
import 'dart:async';
import 'package:app_properties/components/loaders/professional_loader.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:flutter/material.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:app_properties/features/incidents/presentation/cubit/incident_state.dart';
import 'package:app_properties/features/incidents/presentation/widgets/incident_card.dart';
import 'package:app_properties/features/incidents/presentation/widgets/incident_detail_sheet.dart';
import 'package:app_properties/features/incidents/presentation/widgets/incident_filters_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class IncidentHistoryPage extends StatefulWidget {
  const IncidentHistoryPage({super.key});

  @override
  State<IncidentHistoryPage> createState() => _IncidentHistoryPageState();
}

class _IncidentHistoryPageState extends State<IncidentHistoryPage> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  // Local state for results
  List<IncidentDetailRowResponse> _incidents = [];
  List<IncidentCategoryModel> _categories = [];
  bool _isLoadingIncidents = false;
  String? _errorMessage;

  // Active filters
  String? _statusFilter;
  String? _priorityFilter;
  int? _incidentTypeFilter;
  int? _sectorFilter;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
      _fetchIncidents();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _fetchIncidents();
    });
  }

  void _fetchCategories() {
    final cubit = context.read<IncidentCubit>();
    final state = cubit.state;
    if (state is IncidentCategoriesLoaded) {
      setState(() {
        _categories = state.categories;
      });
    } else {
      cubit.loadIncidentCategories();
    }
  }

  void _fetchIncidents() {
    setState(() {
      _isLoadingIncidents = true;
      _errorMessage = null;
    });

    final connectionId = _searchController.text.trim();
    context.read<IncidentCubit>().loadIncidents(
      connectionId: connectionId.isEmpty ? null : connectionId,
      status: _statusFilter,
      priority: _priorityFilter,
      incidentTypeId: _incidentTypeFilter,
      sector: _sectorFilter,
    );
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _priorityFilter = null;
      _incidentTypeFilter = null;
      _sectorFilter = null;
      _searchController.clear();
    });
    _fetchIncidents();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return IncidentFiltersBottomSheet(
          initialStatus: _statusFilter,
          initialPriority: _priorityFilter,
          initialTypeId: _incidentTypeFilter,
          initialSector: _sectorFilter,
          categories: _categories,
          onApply: (status, priority, typeId, sector) {
            setState(() {
              _statusFilter = status;
              _priorityFilter = priority;
              _incidentTypeFilter = typeId;
              _sectorFilter = sector;
            });
            _fetchIncidents();
          },
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICA':
        return const Color(0xFFC62828);
      case 'ALTA':
        return const Color(0xFFE65100);
      case 'MEDIA':
        return const Color(0xFF1565C0);
      case 'BAJA':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
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

  void _showIncidentDetail(IncidentDetailRowResponse incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return IncidentDetailSheet(
          incident: incident,
          statusColor: _getStatusColor(incident.status),
          statusLabel: _getStatusLabel(incident.status),
          priorityColor: _getPriorityColor(incident.suggestedPriority),
          getImageUrl: _getImageUrl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<IncidentCubit, IncidentState>(
      listener: (context, state) {
        if (state is IncidentCategoriesLoaded) {
          setState(() {
            _categories = state.categories;
          });
        } else if (state is IncidentsLoaded) {
          setState(() {
            _incidents = state.incidents;
            _isLoadingIncidents = false;
            _errorMessage = null;
          });
        } else if (state is IncidentError) {
          setState(() {
            _errorMessage = state.message;
            _isLoadingIncidents = false;
          });
        }
      },
      builder: (context, state) {
        final hasActiveFilters =
            _statusFilter != null ||
            _priorityFilter != null ||
            _incidentTypeFilter != null ||
            _sectorFilter != null ||
            _searchController.text.isNotEmpty;

        return Scaffold(
          backgroundColor: cs.surface,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.surface, cs.surfaceContainerLow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Fixed Header: AppBar section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historial',
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Incidencias Reportadas',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasActiveFilters)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: cs.error,
                            ),
                            icon: const Icon(Icons.clear_all_rounded, size: 16),
                            label: const Text(
                              'Limpiar',
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: _clearFilters,
                          ),
                      ],
                    ),
                  ),

                  // Fixed Header: Search and Filters Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por código de acometida...',
                                hintStyle: TextStyle(
                                  color: cs.onSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: cs.primary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _searchController.clear(),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _showFilterSheet,
                          child: Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color:
                                (_statusFilter != null ||
                                    _priorityFilter != null ||
                                    _incidentTypeFilter != null ||
                                    _sectorFilter != null)
                                    ? cs.primary
                                    : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color:
                                (_statusFilter != null ||
                                    _priorityFilter != null ||
                                    _incidentTypeFilter != null ||
                                    _sectorFilter != null)
                                    ? cs.onPrimary
                                    : cs.primary,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fixed Header: Active Filter Chips view
                  if (_statusFilter != null ||
                      _priorityFilter != null ||
                      _incidentTypeFilter != null ||
                      _sectorFilter != null)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          if (_statusFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: _getStatusColor(
                                  _statusFilter!,
                                ).withValues(alpha: 0.12),
                                side: BorderSide(
                                  color: _getStatusColor(
                                    _statusFilter!,
                                  ).withValues(alpha: 0.3),
                                ),
                                label: Text(
                                  _getStatusLabel(_statusFilter!),
                                  style: TextStyle(
                                    color: _getStatusColor(_statusFilter!),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() => _statusFilter = null);
                                  _fetchIncidents();
                                },
                              ),
                            ),
                          if (_priorityFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: _getPriorityColor(
                                  _priorityFilter!,
                                ).withValues(alpha: 0.12),
                                side: BorderSide(
                                  color: _getPriorityColor(
                                    _priorityFilter!,
                                  ).withValues(alpha: 0.3),
                                ),
                                label: Text(
                                  'Prioridad: ${_priorityFilter!}',
                                  style: TextStyle(
                                    color: _getPriorityColor(_priorityFilter!),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() => _priorityFilter = null);
                                  _fetchIncidents();
                                },
                              ),
                            ),
                          if (_incidentTypeFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: cs.primaryContainer,
                                side: BorderSide(
                                  color: cs.primary.withValues(alpha: 0.3),
                                ),
                                label: Builder(
                                  builder: (context) {
                                    String name = 'Tipo: $_incidentTypeFilter';
                                    for (var cat in _categories) {
                                      for (var type in cat.incidentTypes) {
                                        if (type.typeCode ==
                                            _incidentTypeFilter) {
                                          name = type.typeName;
                                          break;
                                        }
                                      }
                                    }
                                    return Text(
                                      name,
                                      style: TextStyle(
                                        color: cs.onPrimaryContainer,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                onDeleted: () {
                                  setState(() => _incidentTypeFilter = null);
                                  _fetchIncidents();
                                },
                              ),
                            ),
                          if (_sectorFilter != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                backgroundColor: cs.primaryContainer,
                                side: BorderSide(
                                  color: cs.primary.withValues(alpha: 0.3),
                                ),
                                label: Text(
                                  'Sector: $_sectorFilter',
                                  style: TextStyle(
                                    color: cs.onPrimaryContainer,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() => _sectorFilter = null);
                                  _fetchIncidents();
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Scrollable Content
                  Expanded(child: _buildListContent(cs)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListContent(ColorScheme cs) {
    if (_isLoadingIncidents) {
      return const ProfessionalLoader(
        label: 'Cargando...',
        description: 'Se está cargando la información',
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                onPressed: _fetchIncidents,
              ),
            ],
          ),
        ),
      );
    }

    if (_incidents.isEmpty) {
      final hasActiveFilters =
          _statusFilter != null ||
          _priorityFilter != null ||
          _incidentTypeFilter != null ||
          _sectorFilter != null ||
          _searchController.text.isNotEmpty;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron incidencias',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba cambiando los criterios de filtrado o la clave de acometida.',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (hasActiveFilters) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Limpiar filtros'),
                  onPressed: _clearFilters,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async => _fetchIncidents(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: _incidents.length,
        itemBuilder: (context, index) {
          final incident = _incidents[index];
          final statusCol = _getStatusColor(incident.status);
          final statusLabel = _getStatusLabel(incident.status);
          final priorityCol = _getPriorityColor(incident.suggestedPriority);

          return IncidentCard(
            incident: incident,
            onTap: () => _showIncidentDetail(incident),
            statusColor: statusCol,
            statusLabel: statusLabel,
            priorityColor: priorityCol,
          );
        },
      ),
    );
  }
}
