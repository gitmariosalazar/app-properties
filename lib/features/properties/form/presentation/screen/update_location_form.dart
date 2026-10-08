import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:app_properties/core/di/injection.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';
import 'package:app_properties/components/common/custom_overlay_snack_bar.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/add_observation_connection.dart';
import 'package:app_properties/features/properties/form/presentation/screen/map_picker_screen.dart';
import 'package:app_properties/features/properties/form/presentation/widgets/connection/gps_section.dart';
import 'package:app_properties/utils/convert_coordinates.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/widgets/mic_suffix_button.dart';
import 'package:app_properties/components/widgets/connection_info_card.dart';

class UpdateLocationFormScreen extends StatefulWidget {
  final ConnectionWithPropertiesEntity connection;

  const UpdateLocationFormScreen({super.key, required this.connection});

  @override
  State<UpdateLocationFormScreen> createState() =>
      _UpdateLocationFormScreenState();
}

class _UpdateLocationFormScreenState extends State<UpdateLocationFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  // Observación
  final _observationDetailsCtrl = TextEditingController();

  // GPS
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cantonCtrl = TextEditingController();
  final _addressFullCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  final _precisionCtrl = TextEditingController();
  final _geolocationDateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadInitialData();
  }

  void _loadInitialData() {
    final conn = widget.connection;
    final coords = extractCoordinates(conn.connectionCoordinates ?? '');

    if (conn.connectionCoordinates?.isNotEmpty == true) {
      _latitudeCtrl.text = coords['latitude']?.toString() ?? '';
      _longitudeCtrl.text = coords['longitude']?.toString() ?? '';
    } else {
      _latitudeCtrl.text = '0.32069990';
      _longitudeCtrl.text = '-78.10616480';
    }

    _accuracyCtrl.text = conn.connectionAltitude?.toStringAsFixed(1) ?? '0.0';
    _precisionCtrl.text =
        conn.connectionPrecision?.toStringAsFixed(2) ?? '0.99';
    _geolocationDateCtrl.text =
        conn.connectionGeolocationDate?.toIso8601String() ??
        DateTime.now().toIso8601String();

    // Attempt reverse geocoding on initial load if coordinates exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lat = double.tryParse(_latitudeCtrl.text) ?? 0.32069990;
      final lng = double.tryParse(_longitudeCtrl.text) ?? -78.10616480;
      _reverseGeocode(lat, lng);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _observationDetailsCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    _countryCtrl.dispose();
    _provinceCtrl.dispose();
    _cantonCtrl.dispose();
    _addressFullCtrl.dispose();
    _accuracyCtrl.dispose();
    _precisionCtrl.dispose();
    _geolocationDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndAddress() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _showErrorSnackBar('Servicio de ubicación desactivado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _showErrorSnackBar('Permiso denegado.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return _showErrorSnackBar('Permiso denegado permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final accuracy = position.accuracy;
      final precision = accuracy <= 5
          ? 0.99
          : accuracy <= 10
          ? 0.95
          : accuracy <= 20
          ? 0.90
          : accuracy <= 50
          ? 0.80
          : 0.50;

      setState(() {
        _latitudeCtrl.text = position.latitude.toStringAsFixed(8);
        _longitudeCtrl.text = position.longitude.toStringAsFixed(8);
        _accuracyCtrl.text = accuracy.toStringAsFixed(1);
        _precisionCtrl.text = precision.toStringAsFixed(2);
        _geolocationDateCtrl.text = DateTime.now().toIso8601String();
      });

      await _reverseGeocode(position.latitude, position.longitude);
      _showSnackBar(
        'Ubicación obtenida con precisión ${precision.toStringAsFixed(2)}',
      );
    } catch (e) {
      _showErrorSnackBar('Error al obtener ubicación: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _countryCtrl.text = place.country ?? 'Ecuador';
          _provinceCtrl.text = place.administrativeArea ?? '';
          _cantonCtrl.text =
              place.subAdministrativeArea ?? place.locality ?? '';
          _addressFullCtrl.text = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
  }

  void _openMap() {
    final lat = double.tryParse(_latitudeCtrl.text) ?? 0.32069990;
    final lng = double.tryParse(_longitudeCtrl.text) ?? -78.10616480;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: lat,
          initialLng: lng,
          onLocationPicked: (lat, lng) async {
            setState(() {
              _latitudeCtrl.text = lat.toStringAsFixed(8);
              _longitudeCtrl.text = lng.toStringAsFixed(8);
              _precisionCtrl.text = '0.99';
              _geolocationDateCtrl.text = DateTime.now().toIso8601String();
            });
            await _reverseGeocode(lat, lng);
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    CustomOverlaySnackBar.show(
      context: context,
      message: message,
      type: SnackBarType.info,
    );
  }

  void _showErrorSnackBar(String message) {
    CustomOverlaySnackBar.show(
      context: context,
      message: message,
      type: SnackBarType.error,
    );
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latitudeCtrl.text);
    final lng = double.tryParse(_longitudeCtrl.text);

    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      _showErrorSnackBar('Debe obtener la ubicación GPS antes de guardar.');
      return;
    }

    setState(() => _isSubmitting = true);

    final conn = widget.connection;
    final alt = double.tryParse(_accuracyCtrl.text) ?? 0.0;
    final prec = double.tryParse(_precisionCtrl.text) ?? 0.0;

    // Reconstruct required ids from existing data to preserve them
    final isNaturalPerson = conn.person != null;
    final clientId = isNaturalPerson
        ? conn.clientId
        : (conn.company?.ruc ?? '');

    final int rateId = conn.connectionRateName == 'BENEFICENCIA'
        ? 1
        : conn.connectionRateName == 'RESIDENCIAL'
        ? 2
        : conn.connectionRateName == 'INDUSTRIAL'
        ? 3
        : 6;

    final int zoneId = conn.zoneName == 'ZONA 1'
        ? 1
        : conn.zoneName == 'ZONA 2'
        ? 2
        : conn.zoneName == 'ZONA 3'
        ? 3
        : conn.zoneName == 'ZONA 4'
        ? 4
        : 0;

    try {
      await sl<UpdateConnectionUseCase>()(
        connectionId: conn.connectionId,
        params: UpdateConnectionParams(
          clientId: clientId,
          connectionRateId: rateId,
          connectionRateName: conn.connectionRateName ?? 'COMERCIAL',
          connectionMeterNumber: conn.connectionMeterNumber ?? '',
          connectionContractNumber: conn.connectionContractNumber ?? '',
          connectionSewerage: conn.connectionSewerage ?? true,
          connectionStatus: conn.connectionStatus ?? true,
          connectionAddress: conn.connectionAddress,
          connectionInstallationDate:
              conn.connectionInstallationDate ??
              DateTime.now().toIso8601String(),
          connectionPeopleNumber: conn.connectionPeopleNumber ?? 1,
          connectionZone: conn.connectionZone ?? 1,
          longitude: lng,
          latitude: lat,
          connectionReference: conn.connectionReference ?? '',
          propertyCadastralKey:
              (conn.propertyCadastralKey == null ||
                  conn.propertyCadastralKey == 'N/A')
              ? null
              : conn.propertyCadastralKey,
          connectionMetaData: {
            'country': _countryCtrl.text,
            'province': _provinceCtrl.text,
            'canton': _cantonCtrl.text,
            'full_address': _addressFullCtrl.text,
            'accuracy_meters': alt,
            'precision': prec,
            'source': 'mobile_app_update_location',
          },
          connectionAltitude: alt,
          connectionPrecision: prec,
          connectionGeolocationDate: _geolocationDateCtrl.text.isNotEmpty
              ? _geolocationDateCtrl.text
              : DateTime.now().toIso8601String(),
          zoneId: zoneId,
        ),
      );

      if (_observationDetailsCtrl.text.trim().isNotEmpty) {
        await sl<AddObservationConnectionUseCase>()(
          params: CreateObservationParams(
            connectionId: conn.connectionId,
            observationTitle: 'Actualización de Ubicación GPS',
            observationDetails: _observationDetailsCtrl.text.trim(),
          ),
        );
      }

      if (mounted) {
        CustomOverlaySnackBar.show(
          context: context,
          message: 'Ubicación GPS actualizada exitosamente',
          type: SnackBarType.success,
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) context.pop();
        });
      }
    } catch (e) {
      _showErrorSnackBar(
        'Error al actualizar ubicación: ${e.toString().replaceAll("Exception: ", "")}',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final conn = widget.connection;
    final clientName = conn.person != null
        ? '${conn.person!.firstName} ${conn.person!.lastName}'
        : conn.company?.businessName ?? 'Sin Cliente Asociado';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'Actualizar Ubicación',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              padding: context.screenPadding,
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de información básica
                    ConnectionInfoCard(connection: conn),
                    const SizedBox(height: 5),

                    FormCard(
                      title: 'Observación o Novedad (Opcional)',
                      child: CustomTextField(
                        controller: _observationDetailsCtrl,
                        label:
                            'Detalles (Motivo del cambio de ubicación, etc.)',
                        icon: Icons.notes,
                        isTextArea: true,
                        isRequired: false,
                        suffixIcon: MicSuffixButton(
                          controller: _observationDetailsCtrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    GpsSection(
                      latitudeCtrl: _latitudeCtrl,
                      longitudeCtrl: _longitudeCtrl,
                      accuracyCtrl: _accuracyCtrl,
                      countryCtrl: _countryCtrl,
                      provinceCtrl: _provinceCtrl,
                      cantonCtrl: _cantonCtrl,
                      addressFullCtrl: _addressFullCtrl,
                      precisionCtrl: _precisionCtrl,
                      geolocationDateCtrl: _geolocationDateCtrl,
                      onGetLocation: _getCurrentLocationAndAddress,
                      onOpenMap: _openMap,
                      isGettingLocation: _isGettingLocation,
                      animationController: _animationController,
                      scaleAnimation: _scaleAnimation,
                    ),

                    const SizedBox(height: 40),
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
                              : 'Actualizar Ubicación',
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
