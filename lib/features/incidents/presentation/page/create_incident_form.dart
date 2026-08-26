// lib/features/incidents/presentation/pages/create_incident_form.dart
import 'dart:io';
import 'package:app_properties/components/widgets/images_section.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_properties/components/text/acometida_id_input_formatter.dart';
import 'package:app_properties/features/incidents/domain/entities/incident-category.model.dart';
import 'package:app_properties/features/reading/domain/entities/reading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app_properties/features/properties/form/presentation/screen/map_picker_screen.dart';

import '../../domain/dto/request/create_incident_request.dart';
import '../cubit/incident_cubit.dart';
import '../cubit/incident_state.dart';

class CreateIncidentForm extends StatefulWidget {
  final String connectionId;
  final Future<List<Reading>> Function(String) getReadingInfo;

  const CreateIncidentForm({
    super.key, 
    required this.connectionId,
    required this.getReadingInfo,
  });

  @override
  State<CreateIncidentForm> createState() => _CreateIncidentFormState();
}

class _CreateIncidentFormState extends State<CreateIncidentForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _referenceAddressController = TextEditingController();
  final _connectionIdController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedCategoryName = 'Seleccionar tipo de incidencia';
  String _selectedCategoryPriority = 'MEDIA';
  final List<File> _photoFiles = [];
  bool _isSubmitting = false;

  // Local state for categories to avoid state loss during cubit state mutations
  List<IncidentCategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesErrorMessage;

  Reading? _searchedReading;
  bool _isSearchingConnection = false;
  String? _connectionSearchError;

  // Geolocation state
  double? _latitude;
  double? _longitude;
  String? _country;
  String? _province;
  String? _canton;
  String? _fullAddress;
  bool _isGettingLocation = false;
  bool _isGeocoding = false;

  // Guest Form State
  bool _isGuest = false;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _connectionIdController.text = widget.connectionId;

    // Check if user is logged out (guest)
    final loginState = context.read<LoginCubit>().state;
    _isGuest = loginState is! LoginSuccess;

    _connectionIdController.addListener(() {
      if (_searchedReading != null &&
          _connectionIdController.text.trim() !=
              _searchedReading!.cadastralKey) {
        setState(() {
          _searchedReading = null;
          _connectionSearchError = null;
          _referenceAddressController.clear();
        });
      }
    });

    if (widget.connectionId.isNotEmpty) {
      _fetchConnectionInfo(widget.connectionId);
    }

    // Initial fetch/cache check
    final currentState = context.read<IncidentCubit>().state;
    if (currentState is IncidentCategoriesLoaded) {
      _categories = currentState.categories;
    } else {
      _isLoadingCategories = true;
      context.read<IncidentCubit>().loadIncidentCategories();
    }

    // Auto-fetch current location
    _getCurrentLocation();
  }

  void _retryLoadingCategories() {
    setState(() {
      _isLoadingCategories = true;
      _categoriesErrorMessage = null;
    });
    context.read<IncidentCubit>().loadIncidentCategories();
  }

  Future<void> _fetchConnectionInfo(String connectionId) async {
    if (connectionId.trim().isEmpty) return;

    setState(() {
      _isSearchingConnection = true;
      _connectionSearchError = null;
      _searchedReading = null;
    });

    try {
      final results = await widget.getReadingInfo(connectionId.trim());
      if (!mounted) return;

      setState(() {
        _isSearchingConnection = false;
        if (results.isNotEmpty) {
          _searchedReading = results.first;
          if (_searchedReading!.connectionLocation?.lat != null &&
              _searchedReading!.connectionLocation?.lng != null) {
            _latitude = _searchedReading!.connectionLocation!.lat;
            _longitude = _searchedReading!.connectionLocation!.lng;
          }
        } else {
          _connectionSearchError = 'Código de conexión no encontrado';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearchingConnection = false;
        _connectionSearchError = 'Error al buscar: ${e.toString()}';
      });
    }
  }

  Future<void> _searchConnection() async {
    final value = _connectionIdController.text.trim();
    final validationError = AcometidaIdValidator.validate(
      value,
      isRequired: true,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }
    await _fetchConnectionInfo(value);
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación GPS está desactivado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación GPS denegado.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación GPS denegado permanentemente.');
      }

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isGettingLocation = false;
      });

      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al obtener ubicación GPS: ${e.toString().replaceAll('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> _openMapPicker() async {
    // Si no hay coordenadas previas, usamos Antonio Ante/Otavalo de referencia
    final initialLat = _latitude ?? 0.3385;
    final initialLng = _longitude ?? -78.1757;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: initialLat,
          initialLng: initialLng,
          onLocationPicked: (lat, lng) {
            Navigator.pop(context, {'lat': lat, 'lng': lng});
          },
        ),
      ),
    );

    if (result != null && mounted) {
      final newLat = result['lat'] as double;
      final newLng = result['lng'] as double;

      setState(() {
        _latitude = newLat;
        _longitude = newLng;
      });

      await _reverseGeocode(newLat, newLng);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    if (!mounted) return;
    setState(() {
      _isGeocoding = true;
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

          // Autocompletar la dirección de referencia si está vacía
          if (_referenceAddressController.text.trim().isEmpty) {
            //_referenceAddressController.text = _fullAddress!;
          }

          _isGeocoding = false;
        });
      } else {
        setState(() {
          _isGeocoding = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  Widget _buildGpsSection(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UBICACIÓN GPS DEL INCIDENTE',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  context,
                  colors,
                  label: 'Latitud',
                  value: _latitude != null
                      ? _latitude!.toStringAsFixed(8)
                      : 'No obtenida',
                  icon: Icons.north_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadOnlyField(
                  context,
                  colors,
                  label: 'Longitud',
                  value: _longitude != null
                      ? _longitude!.toStringAsFixed(8)
                      : 'No obtenida',
                  icon: Icons.east_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isGeocoding)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Extrayendo dirección...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_fullAddress != null) ...[
            _buildGpsInfoRow(
              context,
              colors,
              icon: Icons.flag_rounded,
              label: 'País',
              value: _country ?? 'Ecuador',
            ),
            const SizedBox(height: 8),
            _buildGpsInfoRow(
              context,
              colors,
              icon: Icons.map_rounded,
              label: 'Provincia',
              value: _province ?? '',
            ),
            const SizedBox(height: 8),
            _buildGpsInfoRow(
              context,
              colors,
              icon: Icons.location_city_rounded,
              label: 'Cantón',
              value: _canton ?? '',
            ),
            const SizedBox(height: 8),
            _buildGpsInfoRow(
              context,
              colors,
              icon: Icons.home_rounded,
              label: 'Dirección Extraída',
              value: _fullAddress!,
              isMultiline: true,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.secondary,
                    foregroundColor: colors.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.my_location_rounded, size: 16),
                  label: const Text(
                    'Obtener GPS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text(
                    'Ver en Mapa',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          if (_searchedReading?.connectionLocation?.lat != null &&
              _searchedReading?.connectionLocation?.lng != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.tertiaryContainer,
                  foregroundColor: colors.onTertiaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _latitude = _searchedReading!.connectionLocation!.lat;
                    _longitude = _searchedReading!.connectionLocation!.lng;
                  });
                },
                icon: const Icon(Icons.location_on, size: 16),
                label: const Text(
                  'Usar ubicación de acometida',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context,
    ColorScheme colors, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsInfoRow(
    BuildContext context,
    ColorScheme colors, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMultiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
      return;
    }
    if (_photoFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor tome al menos una foto')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    if (_latitude == null || _longitude == null) {
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('El servicio de ubicación GPS está desactivado.');
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw Exception('Permiso de ubicación GPS denegado.');
          }
        }
        if (permission == LocationPermission.deniedForever) {
          throw Exception('Permiso de ubicación GPS denegado permanentemente.');
        }

        const locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        final position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        _latitude = position.latitude;
        _longitude = position.longitude;
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al obtener ubicación GPS: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
        return;
      }
    }

    final connectionIdVal = _connectionIdController.text.trim();

    ReportClient? clientData;
    if (_isGuest) {
      clientData = ReportClient(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        cellPhone: _cellPhoneController.text.trim().isEmpty
            ? null
            : _cellPhoneController.text.trim(),
      );
    }

    final request = CreateIncidentRequest(
      connectionId: connectionIdVal.isEmpty ? null : connectionIdVal,
      incidentTypeId: _selectedCategoryId!,
      reportDescription: _descriptionController.text.trim(),
      referenceAddress: _referenceAddressController.text.trim().isEmpty
          ? (_searchedReading?.address ?? '')
          : _referenceAddressController.text.trim(),
      reportOrigin: 'WEB_USUARIO',
      priority: _selectedCategoryPriority,
      latitude: _latitude!,
      longitude: _longitude!,
      images: _photoFiles,
      reportClient: clientData,
    );

    if (!mounted) return;
    await context.read<IncidentCubit>().createIncident(request: request);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cellPhoneController.dispose();
    _descriptionController.dispose();
    _connectionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reportar Incidencia',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: BlocConsumer<IncidentCubit, IncidentState>(
        listener: (context, state) {
          if (state is IncidentCategoriesLoaded) {
            setState(() {
              _categories = state.categories;
              _isLoadingCategories = false;
              _categoriesErrorMessage = null;
            });
          } else if (state is IncidentLoading) {
            if (!_isSubmitting) {
              setState(() {
                _isLoadingCategories = true;
                _categoriesErrorMessage = null;
              });
            }
          } else if (state is IncidentOperationSuccess) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.pop();
          } else if (state is IncidentError) {
            setState(() => _isSubmitting = false);
            if (_categories.isEmpty && _isLoadingCategories) {
              setState(() {
                _isLoadingCategories = false;
                _categoriesErrorMessage = state.message;
              });
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Código de Conexión
                _buildConnectionIdField(context, colors),
                const SizedBox(height: 24),

                // 1.5. Datos del Usuario (Solo si es Invitado)
                if (_isGuest) ...[
                  _buildGuestSection(context, colors),
                  const SizedBox(height: 24),
                ],

                // 2. Foto de Evidencia (Obligatorio)
                _buildPhotoSection(context),
                const SizedBox(height: 24),

                // 3. Tipo de Incidencia (Dropdown)
                _buildCategoryDropdown(context, colors),
                const SizedBox(height: 24),

                // 4. Descripción (Obligatorio)
                _buildDescriptionField(context, colors),
                const SizedBox(height: 24),

                // 4.5. Dirección de Referencia (Obligatorio)
                _buildReferenceAddressField(context, colors),
                const SizedBox(height: 24),

                // 4.75. Geolocalización (GPS)
                _buildGpsSection(context, colors),
                const SizedBox(height: 32),

                // 5. Botones de Acción (Cancelar y Enviar)
                _buildActionButtons(context, colors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionIdField(BuildContext context, ColorScheme colors) {
    final isPreFilled = widget.connectionId.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPreFilled
              ? 'Código de Conexión (Asociado)'
              : 'Código de Conexión (Opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _connectionIdController,
          readOnly: isPreFilled,
          enabled: !_isSubmitting && !_isSearchingConnection,
          keyboardType: isPreFilled
              ? TextInputType.text
              : const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: isPreFilled
              ? null
              : [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  AcometidaIdInputFormatter(),
                ],
          validator: isPreFilled
              ? null
              : (value) =>
                    AcometidaIdValidator.validate(value, isRequired: false),
          onFieldSubmitted: (_) => isPreFilled ? null : _searchConnection(),
          decoration: InputDecoration(
            hintText: 'Ej. 1-125',
            prefixIcon: Icon(
              isPreFilled ? Icons.lock_outline : Icons.tag,
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            suffixIcon: isPreFilled
                ? null
                : _isSearchingConnection
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchConnection,
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            filled: true,
            fillColor: isPreFilled
                ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                : colors.surfaceContainerHighest,
          ),
        ),
        _buildConnectionInfoCard(context, colors),
      ],
    );
  }

  Widget _buildConnectionInfoCard(BuildContext context, ColorScheme colors) {
    if (_isSearchingConnection) {
      return const SizedBox.shrink();
    }

    if (_connectionSearchError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _connectionSearchError!,
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchedReading == null) {
      return const SizedBox.shrink();
    }

    final reading = _searchedReading!;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.outlineVariant),
        ),
        color: colors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person_pin, color: colors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reading.clientName ?? 'Propietario Desconocido',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.cable, color: colors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          reading.cadastralKey ?? 'Sin Acometida',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
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
                      Icons.badge_outlined,
                      'CI/RUC',
                      reading.cardId ?? 'Sin CI/RUC',
                      colors,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.speed_outlined,
                      'Medidor',
                      reading.meterNumber ?? 'Sin medidor',
                      colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_outlined,
                'Dirección',
                reading.address ?? 'No disponible',
                colors,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.info_outline,
                      'Estado',
                      reading.connectionStateName ?? 'Sin estado',
                      colors,
                      valueColor: reading.permitReading == false
                          ? colors.error
                          : colors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.money,
                      'Tarifa',
                      reading.rateName ?? 'Sin tarifa',
                      colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.north,
                      'Latitud',
                      reading.connectionLocation?.lat?.toString() ??
                          'No disponible',
                      colors,
                      valueColor: reading.permitReading == false
                          ? colors.error
                          : colors.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.south,
                      'Longitud',
                      reading.connectionLocation?.lng?.toString() ??
                          'No disponible',
                      colors,
                      valueColor: reading.permitReading == false
                          ? colors.error
                          : colors.onTertiaryContainer,
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
    IconData icon,
    String label,
    String value,
    ColorScheme colors, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: valueColor ?? colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return ImagesSection(
      attachedImages: _photoFiles,
      mode: 'create',
      onImageAdded: (file) {
        if (!_isSubmitting) {
          setState(() {
            _photoFiles.add(file);
          });
        }
      },
      onImageRemoved: (index) {
        if (!_isSubmitting) {
          setState(() {
            _photoFiles.removeAt(index);
          });
        }
      },
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, ColorScheme colors) {
    Widget content;
    VoidCallback? onTap;

    if (_isLoadingCategories) {
      content = Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cargando categorías...',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
        ],
      );
      onTap = null;
    } else if (_categoriesErrorMessage != null) {
      content = Row(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error al cargar. Toca para reintentar.',
              style: TextStyle(
                fontSize: 14,
                color: colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.refresh, color: colors.error),
        ],
      );
      onTap = _retryLoadingCategories;
    } else {
      content = Row(
        children: [
          Expanded(
            child: Text(
              _selectedCategoryName,
              style: TextStyle(
                fontSize: 14,
                color: _selectedCategoryId == null
                    ? colors.onSurfaceVariant.withOpacity(0.7)
                    : colors.onSurface,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
        ],
      );
      onTap = () => _showCategoryPicker(context, colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Incidencia *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSubmitting ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _categoriesErrorMessage != null
                    ? colors.error.withOpacity(0.5)
                    : colors.outlineVariant,
              ),
            ),
            child: content,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority, ColorScheme colors) {
    switch (priority.toUpperCase()) {
      case 'CRITICA':
      case 'CRÍTICA':
        return Colors.red.shade900;
      case 'ALTA':
        return Colors.red.shade600;
      case 'MEDIA':
        return Colors.orange.shade700;
      case 'BAJA':
      default:
        return Colors.green.shade600;
    }
  }

  void _showCategoryPicker(BuildContext context, ColorScheme colors) {
    IncidentCategoryModel? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final isShowingTypes = selectedCategory != null;
          final titleText = isShowingTypes
              ? selectedCategory!.name
              : 'Seleccionar Categoría';
          final itemsList = isShowingTypes
              ? selectedCategory!.incidentTypes
              : _categories;

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) {
              return Material(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Drag Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.onSurfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            if (isShowingTypes)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: colors.onSurface,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    selectedCategory = null;
                                  });
                                },
                              )
                            else
                              const SizedBox(
                                width: 48,
                              ), // Match back button spacing
                            Expanded(
                              child: Text(
                                titleText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Balance spacing
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      Expanded(
                        child: _categories.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      size: 48,
                                      color: colors.onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hay categorías disponibles',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: itemsList.length,
                                itemBuilder: (context, index) {
                                  final item = itemsList[index];
                                  if (!isShowingTypes) {
                                    // Render Category item
                                    final category =
                                        item as IncidentCategoryModel;
                                    return ListTile(
                                      title: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      subtitle: category.description != null
                                          ? Text(
                                              category.description!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: colors.onSurfaceVariant
                                                    .withOpacity(0.8),
                                              ),
                                            )
                                          : null,
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      onTap: () {
                                        setModalState(() {
                                          selectedCategory = category;
                                        });
                                      },
                                    );
                                  } else {
                                    // Render IncidentType item
                                    final type = item as IncidentTypeModel;
                                    final isSelected =
                                        _selectedCategoryId == type.typeCode;
                                    return ListTile(
                                      leading: isSelected
                                          ? Icon(
                                              Icons.check_circle_rounded,
                                              color: colors.primary,
                                            )
                                          : Icon(
                                              Icons.circle_outlined,
                                              color: colors.onSurfaceVariant,
                                            ),
                                      title: Text(
                                        type.typeName,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color: isSelected
                                              ? colors.primary
                                              : colors.onSurface,
                                        ),
                                      ),
                                      subtitle: Text(
                                        type.typeDescription,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colors.onSurfaceVariant
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            type.suggestedPriority,
                                            colors,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          type.suggestedPriority,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: _getPriorityColor(
                                              type.suggestedPriority,
                                              colors,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _selectedCategoryId = type.typeCode;
                                          _selectedCategoryName = type.typeName;
                                          _selectedCategoryPriority =
                                              type.suggestedPriority;
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, ColorScheme colors) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      enabled: !_isSubmitting,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Descripción es obligatoria';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Descripción de la Incidencia *',
        hintText: 'Describe el problema en detalle...',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildReferenceAddressField(BuildContext context, ColorScheme colors) {
    return TextFormField(
      controller: _referenceAddressController,
      enabled: !_isSubmitting,
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Dirección de referencia es obligatoria';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Dirección de Referencia *',
        hintText: 'Describe la dirección de referencia...',
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colors.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/inicio');
                      }
                    },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.cancel_rounded, size: 18),
              label: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting ? 'Registrando...' : 'Registrar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSection(BuildContext context, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DATOS DEL SOLICITANTE (OBLIGATORIO)',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  enabled: !_isSubmitting,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Nombres *',
                    hintText: 'Ej. Juan',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  enabled: !_isSubmitting,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Apellidos *',
                    hintText: 'Ej. Pérez',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final emailEmpty = value == null || value.trim().isEmpty;
                    final phoneEmpty = _cellPhoneController.text.trim().isEmpty;

                    if (emailEmpty && phoneEmpty) {
                      return 'Obligatorio si\nno hay teléfono';
                    }
                    if (!emailEmpty &&
                        !RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    hintText: 'Ej. a@a.com',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cellPhoneController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final phoneEmpty = value == null || value.trim().isEmpty;
                    final emailEmpty = _emailController.text.trim().isEmpty;

                    if (phoneEmpty && emailEmpty) {
                      return 'Obligatorio si\nno hay correo';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ej. 098...',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: colors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
