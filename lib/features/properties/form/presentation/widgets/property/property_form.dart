import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_properties/core/di/injection.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/features/properties/search/domain/entities/property_with_client.dart';
import 'package:app_properties/features/properties/search/domain/usecases/find_property_with_client.dart';

class PropertyForm extends StatefulWidget {
  final String clientId;
  final TextEditingController propertyCadastralKeyCtrl;
  final TextEditingController propertyAddressCtrl;
  final TextEditingController alleywayCtrl;
  final TextEditingController landAreaCtrl;
  final TextEditingController constructionAreaCtrl;
  final TextEditingController landValueCtrl;
  final TextEditingController constructionValueCtrl;
  final void Function(PropertyWithClientEntity?)? onPropertySelected;

  const PropertyForm({
    super.key,
    required this.clientId,
    required this.propertyCadastralKeyCtrl,
    required this.propertyAddressCtrl,
    required this.alleywayCtrl,
    required this.landAreaCtrl,
    required this.constructionAreaCtrl,
    required this.landValueCtrl,
    required this.constructionValueCtrl,
    this.onPropertySelected,
  });

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FindPropertyWithClient _findPropertyWithClient = sl<FindPropertyWithClient>();
  
  List<PropertyWithClientEntity> _properties = [];
  PropertyWithClientEntity? _selectedProperty;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;
  bool _initiallyUnlinked = false;

  @override
  void initState() {
    super.initState();
    _initiallyUnlinked = widget.propertyCadastralKeyCtrl.text.isEmpty ||
        widget.propertyCadastralKeyCtrl.text == 'N/A';
    _performInitialSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _performInitialSearch() async {
    if (widget.clientId.isEmpty || widget.clientId == 'N/A') return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _findPropertyWithClient(widget.clientId);
      setState(() {
        _properties = results;
        _isLoading = false;
      });

      // Si hay una clave seleccionada actualmente, intentamos emparejarla con la búsqueda
      final currentKey = widget.propertyCadastralKeyCtrl.text;
      if (currentKey.isNotEmpty && currentKey != 'N/A') {
        final matchIndex = results.indexWhere((p) => p.propertyCadastralKey == currentKey);
        if (matchIndex != -1) {
          setState(() {
            _selectedProperty = results[matchIndex];
          });
        } else {
          // Si no está en los resultados del cliente, hacemos búsqueda directa por clave catastral
          _searchDirectlyForCurrentKey(currentKey);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudieron cargar los predios del cliente automáticamente.';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchDirectlyForCurrentKey(String key) async {
    try {
      final results = await _findPropertyWithClient(key);
      if (results.isNotEmpty) {
        setState(() {
          _selectedProperty = results.first;
          // Agregamos al principio de la lista si no está
          if (!_properties.any((p) => p.propertyCadastralKey == key)) {
            _properties.insert(0, results.first);
          }
        });
      }
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().length >= 3) {
        _searchProperties(query.trim());
      } else if (query.trim().isEmpty) {
        _performInitialSearch();
      }
    });
  }

  Future<void> _searchProperties(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _findPropertyWithClient(query);
      setState(() {
        _properties = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al realizar la búsqueda. Verifique su conexión.';
        _isLoading = false;
      });
    }
  }

  void _selectProperty(PropertyWithClientEntity property) {
    setState(() {
      _selectedProperty = property;
    });
    widget.propertyCadastralKeyCtrl.text = property.propertyCadastralKey ?? 'N/A';
    widget.propertyAddressCtrl.text = property.propertyAddress ?? '';
    widget.alleywayCtrl.text = property.propertyAlleyway ?? '';
    widget.landAreaCtrl.text = '';
    widget.constructionAreaCtrl.text = '';
    widget.landValueCtrl.text = '';
    widget.constructionValueCtrl.text = '';
    widget.onPropertySelected?.call(property);
  }

  void _clearSelection() {
    setState(() {
      _selectedProperty = null;
    });
    widget.propertyCadastralKeyCtrl.text = 'N/A';
    widget.propertyAddressCtrl.text = '';
    widget.alleywayCtrl.text = '';
    widget.landAreaCtrl.text = '';
    widget.constructionAreaCtrl.text = '';
    widget.landValueCtrl.text = '';
    widget.constructionValueCtrl.text = '';
    widget.onPropertySelected?.call(null);
  }

  String _getClientName(PropertyWithClientEntity p) {
    if (p.person != null) {
      final firstName = p.person!.firstName ?? '';
      final lastName = p.person!.lastName ?? '';
      return '$firstName $lastName'.trim();
    } else if (p.company != null) {
      return p.company!.businessName ?? p.company!.commercialName ?? 'Persona Jurídica';
    }
    return 'Sin Propietario Asociado';
  }

  String _getClientId(PropertyWithClientEntity p) {
    if (p.person != null) {
      return p.person!.personId;
    } else if (p.company != null) {
      return p.company!.ruc;
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCurrentSelectionCard(context),
        context.vSpace(0.025),
        _buildSearchField(context),
        context.vSpace(0.02),
        if (_isLoading)
          _buildLoadingState(context)
        else if (_errorMessage != null)
          _buildErrorState(context)
        else
          _buildPropertiesList(context),
      ],
    );
  }

  Widget _buildCurrentSelectionCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    const selectedGreen = Color(0xFF2E7D32);
    const selectedGreenBg = Color(0xFFE8F5E9);
    const selectedGreenBgDark = Color(0xFF1B3A1B);

    if (_selectedProperty == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: cs.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acometida sin Predio Asociado',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esta acometida se encuentra actualmente sin vinculación a ningún predio catastral. '
                    'Puede utilizar el buscador inferior para localizar y asociar un predio existente en el catastro, '
                    'o bien continuar y finalizar el proceso manteniéndola desasociada.',
                    style: context.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? selectedGreenBgDark : selectedGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selectedGreen.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: selectedGreen.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: selectedGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Predio Seleccionado',
                style: context.bodyMedium.copyWith(
                  color: selectedGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: selectedGreen, size: 18),
                onPressed: _clearSelection,
                tooltip: 'Desasociar predio',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedProperty!.propertyAddress ?? 'Sin dirección registrada',
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : selectedGreen,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 6),
              Text(
                'Clave: ${_selectedProperty!.propertyCadastralKey ?? "Sin clave"}',
                style: context.bodySmall.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Propietario: ${_getClientName(_selectedProperty!)} (${_getClientId(_selectedProperty!)})',
                  style: context.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.8),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: context.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar predio por clave, cédula/RUC o nombre...',
                hintStyle: context.bodyMedium.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search, color: cs.primary),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                        onPressed: () {
                          _searchCtrl.clear();
                          _performInitialSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              final query = _searchCtrl.text.trim();
              if (query.isNotEmpty) {
                _searchProperties(query);
              }
            },
            tooltip: 'Buscar predio',
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Buscando predios en el catastro...',
            style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: context.bodyMedium.copyWith(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesList(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    const selGreen = Color(0xFF2E7D32);
    const selGreenBg = Color(0xFFE8F5E9);
    const selGreenBgDark = Color(0xFF1B3A1B);

    if (_properties.isEmpty) {
      return FormCard(
        title: 'Predios del Catastro',
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.search_off_outlined, color: cs.tertiary, size: 40),
              const SizedBox(height: 12),
              Text(
                'No se encontraron predios para la búsqueda actual.',
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Intente ingresar un número de cédula diferente, una clave catastral o use la opción de "Dejar Vacío" si no hay predio vinculado.',
                textAlign: TextAlign.center,
                style: context.bodySmall.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      );
    }

    return FormCard(
      title: 'Predios Encontrados (${_properties.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resultados de la búsqueda',
                style: context.bodySmall.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              TextButton.icon(
                icon: Icon(Icons.remove_circle_outline, size: 14, color: cs.error),
                label: Text('Dejar Vacío', style: TextStyle(color: cs.error, fontWeight: FontWeight.w600, fontSize: 12)),
                onPressed: _clearSelection,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];
          final isSelected = _selectedProperty?.propertyCadastralKey == property.propertyCadastralKey;

          final cardBg = isSelected ? (isDark ? selGreenBgDark : selGreenBg) : null;
          final textColorMain = isSelected ? selGreen : cs.onSurface;
          final textColorSub = isSelected ? selGreen : cs.onSurfaceVariant;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selGreen.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Card(
              elevation: isSelected ? 4 : 1,
              color: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(color: selGreen, width: 1.5)
                    : BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.5),
              ),
              child: ExpansionTile(
                backgroundColor: cardBg,
                collapsedBackgroundColor: isSelected ? cardBg : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                leading: CircleAvatar(
                  backgroundColor: (isSelected ? selGreen : cs.primary).withValues(alpha: 0.1),
                  child: Icon(
                    isSelected ? Icons.check : Icons.home,
                    color: isSelected ? selGreen : cs.primary,
                    size: 18,
                  ),
                ),
                title: Text(
                  property.propertyAddress ?? 'Dirección no registrada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColorMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Clave: ${property.propertyCadastralKey ?? "Sin Clave"}',
                  style: TextStyle(
                    color: textColorSub,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    color: cardBg ?? cs.surfaceContainerHighest.withValues(alpha: 0.2),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(context, 'Sector', property.propertySector),
                        _buildDetailRow(context, 'Tipo de Predio', property.propertyTypeName),
                        _buildDetailRow(context, 'Callejón / Pasaje', property.propertyAlleyway),
                        _buildDetailRow(context, 'Propietario', _getClientName(property)),
                        _buildDetailRow(context, 'Identificación', _getClientId(property)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSelected ? null : () => _selectProperty(property),
                            icon: Icon(
                              isSelected ? Icons.check : Icons.touch_app,
                              size: 16,
                            ),
                            label: Text(
                              isSelected ? 'Seleccionado' : 'Asociar a la Acometida',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? cs.surfaceContainerHighest : selGreen,
                              foregroundColor: isSelected ? cs.onSurfaceVariant : Colors.white,
                              elevation: isSelected ? 0 : 2,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
          );
        },
      ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    final cs = Theme.of(context).colorScheme;
    final displayValue = value?.isNotEmpty == true ? value! : 'N/A';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                color: displayValue == 'N/A' ? cs.onSurfaceVariant : cs.onSurface,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
