// lib/features/incidents/presentation/widgets/incident_filters_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:go_router/go_router.dart';

class IncidentFiltersBottomSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialPriority;
  final int? initialTypeId;
  final int? initialSector;
  final List<IncidentCategoryModel> categories;
  final Function(String?, String?, int?, int?) onApply;

  const IncidentFiltersBottomSheet({
    super.key,
    required this.initialStatus,
    required this.initialPriority,
    required this.initialTypeId,
    required this.initialSector,
    required this.categories,
    required this.onApply,
  });

  @override
  State<IncidentFiltersBottomSheet> createState() =>
      _IncidentFiltersBottomSheetState();
}

class _IncidentFiltersBottomSheetState
    extends State<IncidentFiltersBottomSheet> {
  String? _status;
  String? _priority;
  int? _typeId;
  int? _sector;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _priority = widget.initialPriority;
    _typeId = widget.initialTypeId;
    _sector = widget.initialSector;
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
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _status = null;
                      _priority = null;
                      _typeId = null;
                      _sector = null;
                    });
                  },
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Status Filter Title
            const _FilterLabel(text: 'ESTADO DE INCIDENCIA'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip(
                    'REPORTADO',
                    'Reportado',
                    const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    'EN_INSPECCION',
                    'En Inspección',
                    Colors.deepPurpleAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    'RESUELTO',
                    'Resuelto',
                    const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    'FALSO_REPORTE',
                    'Falso Reporte',
                    const Color(0xFFC62828),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Priority Filter Title
            const _FilterLabel(text: 'PRIORIDAD'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPriorityChip(
                    'BAJA',
                    'Baja',
                    const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityChip(
                    'MEDIA',
                    'Media',
                    const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityChip(
                    'ALTA',
                    'Alta',
                    const Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityChip(
                    'CRITICA',
                    'Crítica',
                    const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Category Dropdown Filter Title
            const _FilterLabel(text: 'TIPO DE INCIDENCIA (CATEGORÍA)'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _typeId,
                  hint: Text(
                    'Todos los tipos de incidencia',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surfaceContainerHigh : cs.surface,
                  items: [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text(
                        'Todos los tipos',
                        style: TextStyle(color: cs.onSurface, fontSize: 13),
                      ),
                    ),
                    ...widget.categories.expand(
                      (cat) => cat.incidentTypes.map(
                        (type) => DropdownMenuItem<int>(
                          value: type.typeCode,
                          child: Text(
                            '${cat.name} - ${type.typeName}',
                            style: TextStyle(color: cs.onSurface, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _typeId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sector Filter Title
            const _FilterLabel(text: 'SECTOR'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _sector,
                  hint: Text(
                    'Todos los sectores',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  isExpanded: true,
                  dropdownColor: isDark ? cs.surfaceContainerHigh : cs.surface,
                  items: [
                    DropdownMenuItem<int>(
                      value: null,
                      child: Text(
                        'Todos los sectores',
                        style: TextStyle(color: cs.onSurface, fontSize: 13),
                      ),
                    ),
                    ...List.generate(40, (index) {
                      final sectorNumber = index + 1;
                      return DropdownMenuItem<int>(
                        value: sectorNumber,
                        child: Text(
                          'Sector $sectorNumber',
                          style: TextStyle(color: cs.onSurface, fontSize: 13),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _sector = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Apply button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  widget.onApply(_status, _priority, _typeId, _sector);
                  context.pop();
                },
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _status == value;

    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? cs.onPrimary : color,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      selectedColor: color,
      side: BorderSide(color: color.withValues(alpha: isSelected ? 1.0 : 0.3)),
      checkmarkColor: cs.onPrimary,
      onSelected: (selected) {
        setState(() {
          _status = selected ? value : null;
        });
      },
    );
  }

  Widget _buildPriorityChip(String value, String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _priority == value;

    return ChoiceChip(
      selected: isSelected,
      label: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? cs.onPrimary : color,
          ),
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      selectedColor: color,
      side: BorderSide(color: color.withValues(alpha: isSelected ? 1.0 : 0.3)),
      onSelected: (selected) {
        setState(() {
          _priority = selected ? value : null;
        });
      },
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;
  const _FilterLabel({required this.text});

  @override
  Widget build(BuildContext context) {
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
}
