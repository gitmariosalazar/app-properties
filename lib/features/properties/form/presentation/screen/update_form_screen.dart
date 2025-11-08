// 📦 Flutter SDK
import 'dart:typed_data';
import 'package:flutter/material.dart';

// 🌍 Paquetes externos
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// 🎨 Temas y estilos
import 'package:app_properties/core/theme/app_colors.dart';

// 🧩 Componentes comunes
import 'package:app_properties/components/button/action_button.dart';
import 'package:app_properties/components/common/custom_text_field.dart';
import 'package:app_properties/components/common/form_card.dart';

// 🧠 Utilidades
import 'package:app_properties/utils/date_utils.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/utils/validators.dart';

// 🏠 Features → Properties → Get
import 'package:app_properties/features/properties/list/domain/entities/connection.dart';

// 🏗️ Features → Properties → Put → Data → Datasources
import 'package:app_properties/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/property_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/observation_connection_remote_data_source.dart';

// 🧱 Features → Properties → Put → Data → Repositories
import 'package:app_properties/features/properties/form/update/data/repositories/company_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/connection_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/customer_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/property_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/observation_connection_repository_impl.dart';

// 🧩 Features → Properties → Put → Domain → Repositories
import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';

// ⚙️ Features → Properties → Put → Domain → UseCases
import 'package:app_properties/features/properties/form/update/domain/usecases/update_company.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_customer.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_property.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/add_observation_connection.dart';

// 🗺️ Features → Properties → Put → Presentation → Screens
import 'package:app_properties/features/properties/form/presentation/screen/map_picker_screen.dart';

// 🧾 Features → Properties → Put → Presentation → Widgets → Client
import 'package:app_properties/features/properties/form/presentation/widgets/client/company_form.dart';
import 'package:app_properties/features/properties/form/presentation/widgets/client/natural_person_form.dart';

// ⚡ Features → Properties → Put → Presentation → Widgets → Connection
import 'package:app_properties/features/properties/form/presentation/widgets/connection/gps_section.dart';
import 'package:app_properties/features/properties/form/presentation/widgets/connection/images_section.dart';

// 🏡 Features → Properties → Put → Presentation → Widgets → Property
import 'package:app_properties/features/properties/form/presentation/widgets/property/property_form.dart';

class UpdateConnectionFormScreen extends StatefulWidget {
  final ConnectionEntity connection;
  final String mode;

  const UpdateConnectionFormScreen({
    super.key,
    required this.connection,
    this.mode = 'manual',
  });

  @override
  State<UpdateConnectionFormScreen> createState() =>
      _UpdateConnectionFormScreenState();
}

class _UpdateConnectionFormScreenState extends State<UpdateConnectionFormScreen>
    with TickerProviderStateMixin {
  // Form Keys
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Controllers & State
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _isNaturalPerson = true;
  bool _isCompany = false;
  bool _isSubmitting = false;
  bool _isDatePickerActive = false;
  bool _isGettingLocation = false;
  bool _hasLoadedGeolocation = false;

  GoogleMapController? _mapController;

  // Observación
  final _observationConnectionIdCtrl = TextEditingController();
  final _observationTitleCtrl = TextEditingController();
  final _observationDetailsCtrl = TextEditingController();

  // Cliente Natural
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _identificationCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final List<TextEditingController> _emailsNatural = [];
  final List<TextEditingController> _phonesNatural = [];

  int _sexId = 1;
  int _civilStatus = 1;
  int _professionId = 1;
  String _originCountry = 'ECU';
  String _identificationType = 'CED';
  String _parishId = '100150';
  bool _deceased = false;

  // Empresa
  final _companyNameCtrl = TextEditingController();
  final _socialReasonCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();
  final List<TextEditingController> _emailsCompany = [];
  final List<TextEditingController> _phonesCompany = [];

  String _companyParishId = '1';
  String _companyCountry = 'ECU';
  String _identificationTypeCompany = 'RUC';

  // Acometida
  final _cadastralKeyCtrl = TextEditingController();
  final _meterNumberCtrl = TextEditingController();
  final _contractNumberCtrl = TextEditingController();
  final _connectionAddressCtrl = TextEditingController();
  final _installationDateCtrl = TextEditingController();
  final _peopleNumberCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _sectorCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();

  // Valores normalizados
  String? _rateName;
  String? _zoneName;

  bool _sewerage = true;
  bool _status = true;
  final _zoneIdCtrl = TextEditingController();
  final _zoneCodeCtrl = TextEditingController();
  final _zoneNameCtrl = TextEditingController();

  // Predio
  final _propertyCadastralKeyCtrl = TextEditingController();
  final _propertyAddressCtrl = TextEditingController();
  final _alleywayCtrl = TextEditingController();
  final _landAreaCtrl = TextEditingController();
  final _constructionAreaCtrl = TextEditingController();
  final _landValueCtrl = TextEditingController();
  final _constructionValueCtrl = TextEditingController();

  // GPS
  final _countryCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cantonCtrl = TextEditingController();
  final _addressFullCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  final _precisionCtrl = TextEditingController();
  final _geolocationDateCtrl = TextEditingController();
  final _geometricZoneCtrl = TextEditingController();

  // Imágenes
  final List<XFile> _selectedImages = [];

  // Listas válidas
  static const _validRates = [
    'RESIDENCIAL',
    'COMERCIAL',
    'INDUSTRIAL',
    'BENEFICENCIA',
  ];
  static const _validZones = [
    'ZONA 1',
    'ZONA 2',
    'ZONA 3',
    'ZONA 4',
    'ZONA NO ASIGNADA',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadInitialData();

    _pageController.addListener(() {
      if (_pageController.page == 1 && !_hasLoadedGeolocation) {
        _hasLoadedGeolocation = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final lat = double.tryParse(_latitudeCtrl.text) ?? -0.180653;
          final lng = double.tryParse(_longitudeCtrl.text) ?? -78.467834;
          _reverseGeocode(lat, lng);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _mapController?.dispose();
    _selectedImages.clear();

    final controllers = [
      _firstNameCtrl,
      _lastNameCtrl,
      _identificationCtrl,
      _dobCtrl,
      _addressCtrl,
      ..._emailsNatural,
      ..._phonesNatural,
      _companyNameCtrl,
      _socialReasonCtrl,
      _rucCtrl,
      _companyAddressCtrl,
      ..._emailsCompany,
      ..._phonesCompany,
      _cadastralKeyCtrl,
      _meterNumberCtrl,
      _contractNumberCtrl,
      _connectionAddressCtrl,
      _installationDateCtrl,
      _peopleNumberCtrl,
      _referenceCtrl,
      _latitudeCtrl,
      _longitudeCtrl,
      _sectorCtrl,
      _accountCtrl,
      _zoneCtrl,
      _propertyCadastralKeyCtrl,
      _propertyAddressCtrl,
      _alleywayCtrl,
      _landAreaCtrl,
      _constructionAreaCtrl,
      _landValueCtrl,
      _constructionValueCtrl,
      _countryCtrl,
      _provinceCtrl,
      _cantonCtrl,
      _addressFullCtrl,
      _accuracyCtrl,
      _precisionCtrl,
      _geolocationDateCtrl,
      _geometricZoneCtrl,
      _observationDetailsCtrl,
      _observationConnectionIdCtrl,
      _observationTitleCtrl,
      _zoneIdCtrl,
      _zoneCodeCtrl,
      _zoneNameCtrl,
    ];
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadInitialData() {
    final conn = widget.connection;

    _isNaturalPerson = conn.person != null;
    _isCompany = conn.company != null;

    // Persona Natural
    if (_isNaturalPerson && conn.person != null) {
      final p = conn.person!;
      _firstNameCtrl.text = p.firstName ?? '';
      _lastNameCtrl.text = p.lastName ?? '';
      _identificationCtrl.text = conn.clientId;
      _dobCtrl.text = p.birthDate ?? '';
      _addressCtrl.text = p.address ?? '';
      _sexId = p.genderId ?? 1;
      _civilStatus = p.civilStatus ?? 1;
      _professionId = p.professionId ?? 1;
      _originCountry = p.country ?? 'ECU';
      _parishId = p.parishId ?? '100150';
      _deceased = p.isDeceased ?? false;

      _emailsNatural.clear();
      _phonesNatural.clear();
      for (var e in p.emails) {
        if (e?.email != null)
          _emailsNatural.add(TextEditingController(text: e!.email));
      }
      for (var p in p.phones) {
        if (p?.numero != null)
          _phonesNatural.add(TextEditingController(text: p!.numero));
      }
      if (_emailsNatural.isEmpty) _emailsNatural.add(TextEditingController());
      if (_phonesNatural.isEmpty) _phonesNatural.add(TextEditingController());
    }

    // Empresa
    if (_isCompany && conn.company != null) {
      final c = conn.company!;
      _companyNameCtrl.text = c.businessName ?? '';
      _socialReasonCtrl.text = c.commercialName ?? '';
      _rucCtrl.text = c.ruc;
      _companyAddressCtrl.text = c.address ?? '';
      _companyParishId = c.parishId ?? '1';
      _companyCountry = c.country ?? 'ECU';

      _emailsCompany.clear();
      _phonesCompany.clear();
      for (var e in c.emails) {
        if (e?.email != null)
          _emailsCompany.add(TextEditingController(text: e!.email));
      }
      for (var p in c.phones) {
        if (p?.numero != null)
          _phonesCompany.add(TextEditingController(text: p!.numero));
      }
      if (_emailsCompany.isEmpty) _emailsCompany.add(TextEditingController());
      if (_phonesCompany.isEmpty) _phonesCompany.add(TextEditingController());
    }

    // Acometida
    _cadastralKeyCtrl.text = conn.connectionCadastralKey ?? '';
    _meterNumberCtrl.text = conn.connectionMeterNumber ?? '';
    _contractNumberCtrl.text = conn.connectionContractNumber ?? '';
    _connectionAddressCtrl.text = conn.connectionAddress;
    _installationDateCtrl.text = conn.connectionInstallationDate ?? '';
    _peopleNumberCtrl.text = conn.connectionPeopleNumber?.toString() ?? '4';
    _referenceCtrl.text = conn.connectionReference ?? '';
    _sectorCtrl.text = conn.connectionSector?.toString() ?? '';
    _accountCtrl.text = conn.connectionAccount?.toString() ?? '';
    _zoneCtrl.text = conn.connectionZone?.toString() ?? '';
    _sewerage = conn.connectionSewerage ?? true;
    _status = conn.connectionStatus ?? true;
    _zoneIdCtrl.text = conn.zoneId?.toString() ?? '';
    _zoneCodeCtrl.text = conn.zoneCode ?? '';
    _zoneNameCtrl.text = conn.zoneName ?? 'ZONA 1';

    // Normalizar tarifa y zona
    _rateName =
        _normalizeValue(conn.connectionRateName, _validRates) ?? 'COMERCIAL';
    _zoneName = _normalizeValue(conn.zoneName, _validZones) ?? 'ZONA 1';

    // Coordenadas
    if (conn.connectionCoordinates?.isNotEmpty == true) {
      final coords = conn.connectionCoordinates!;
      if (coords.contains(',')) {
        final parts = coords.split(',');
        _latitudeCtrl.text = parts[0].trim();
        _longitudeCtrl.text = parts[1].trim();
      } else if (coords.startsWith('0101000020')) {
        try {
          final hex = coords.substring(10);
          final bytes = hexToBytes(hex);
          final lng = bytesToDouble(bytes, 0, littleEndian: true);
          final lat = bytesToDouble(bytes, 8, littleEndian: true);
          _latitudeCtrl.text = lat.toStringAsFixed(8);
          _longitudeCtrl.text = lng.toStringAsFixed(8);
        } catch (e) {
          _latitudeCtrl.text = '-0.180653';
          _longitudeCtrl.text = '-78.467834';
        }
      } else {
        _latitudeCtrl.text = '-0.180653';
        _longitudeCtrl.text = '-78.467834';
      }
    } else {
      _latitudeCtrl.text = '-0.180653';
      _longitudeCtrl.text = '-78.467834';
    }

    _accuracyCtrl.text = conn.connectionAltitude?.toStringAsFixed(1) ?? '0.0';
    _precisionCtrl.text =
        conn.connectionPrecision?.toStringAsFixed(2) ?? '0.99';
    _geolocationDateCtrl.text =
        conn.connectionGeolocationDate?.toIso8601String() ??
        DateTime.now().toIso8601String();
    _geometricZoneCtrl.text = conn.connectionGeometricZone ?? '';

    // Predio
    final firstProp = conn.properties?.isNotEmpty == true
        ? conn.properties!.first
        : null;
    _propertyCadastralKeyCtrl.text =
        firstProp?.propertyCadastralKey ?? conn.connectionCadastralKey ?? '';
    _propertyAddressCtrl.text =
        firstProp?.propertyAddress ?? conn.connectionAddress;
    _alleywayCtrl.text = firstProp?.propertyAlleyway ?? '';

    // Observación
    _observationConnectionIdCtrl.text = conn.connectionId;
    _observationTitleCtrl.text = 'Actualización de Acometida y Predio';
    _observationDetailsCtrl.text = '';
  }

  String? _normalizeValue(String? value, List<String> validList) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    return validList.contains(normalized) ? normalized : null;
  }

  List<int> hexToBytes(String hex) {
    final bytes = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  double bytesToDouble(
    List<int> bytes,
    int offset, {
    bool littleEndian = true,
  }) {
    final byteData = ByteData(8);
    for (int i = 0; i < 8; i++) {
      byteData.setUint8(i, bytes[offset + (littleEndian ? i : 7 - i)]);
    }
    return byteData.getFloat64(0, littleEndian ? Endian.little : Endian.big);
  }

  // Métodos Auxiliares
  Future<void> _selectDate(TextEditingController controller) async {
    if (_isDatePickerActive) return;
    _isDatePickerActive = true;
    try {
      final initial = controller.text.isNotEmpty
          ? DateTime.tryParse(controller.text) ?? DateTime.now()
          : DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        ),
      );
      if (date != null && mounted) {
        final formatted =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        setState(() => controller.text = formatted);
      }
    } finally {
      _isDatePickerActive = false;
    }
  }

  Future<void> _getCurrentLocationAndAddress() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _showSnackBar(
          'El servicio de ubicación está desactivado.',
          error: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _showSnackBar('Permiso de ubicación denegado.', error: true);
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return _showSnackBar('Permiso denegado permanentemente.', error: true);
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
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (e) {
      _showSnackBar('Error al obtener ubicación: $e', error: true);
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
      _showSnackBar('Error al obtener dirección.', error: true);
    }
  }

  void _openMap() {
    final lat = double.tryParse(_latitudeCtrl.text) ?? -0.180653;
    final lng = double.tryParse(_longitudeCtrl.text) ?? -78.467834;
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
    ).then((_) {
      final updatedLat = double.tryParse(_latitudeCtrl.text) ?? -0.180653;
      final updatedLng = double.tryParse(_longitudeCtrl.text) ?? -78.467834;
      _reverseGeocode(updatedLat, updatedLng);
    });
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            context.hSpace(0.01),
            Text(
              '¡Datos actualizados correctamente!',
              style: context.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.cardBorderRadiusValue),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () => context.pop());
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _confirmSubmit();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/home');
    }
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar Guardado', style: context.titleMedium),
        content: Text(
          '¿Desea guardar todos los cambios?',
          style: context.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!confirmed!) return;

    setState(() => _isSubmitting = true);
    final client = http.Client();

    try {
      if (_isNaturalPerson) {
        await UpdateCustomerUseCase(
          CustomerRepositoryImpl(
            remoteDataSource: CustomerRemoteDataSource(client: client),
          ),
        )(
          customerId: _identificationCtrl.text,
          params: UpdateCustomerParams(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            emails: _emailsNatural
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            phoneNumbers: _phonesNatural
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            dateOfBirth: _dobCtrl.text,
            sexId: _sexId,
            civilStatus: _civilStatus,
            address: _addressCtrl.text,
            professionId: _professionId,
            originCountry: _originCountry,
            identificationType: _identificationType,
            parishId: _parishId,
            deceased: _deceased,
          ),
        );
      } else if (_isCompany) {
        await UpdateCompanyUseCase(
          CompanyRepositoryImpl(
            remoteDataSource: CompanyRemoteDataSource(client: client),
          ),
        )(
          companyRuc: _rucCtrl.text,
          params: UpdateCompanyParams(
            companyName: _companyNameCtrl.text,
            socialReason: _socialReasonCtrl.text,
            companyAddress: _companyAddressCtrl.text,
            companyParishId: _companyParishId,
            companyCountry: _companyCountry,
            companyEmails: _emailsCompany
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            companyPhones: _phonesCompany
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            identificationType: _identificationTypeCompany,
          ),
        );
      }

      final lat = double.tryParse(_latitudeCtrl.text) ?? 0.0;
      final lng = double.tryParse(_longitudeCtrl.text) ?? 0.0;
      final alt = double.tryParse(_accuracyCtrl.text) ?? 0.0;
      final prec = double.tryParse(_precisionCtrl.text) ?? 0.0;

      await UpdateConnectionUseCase(
        ConnectionRepositoryImpl(
          remoteDataSource: ConnectionRemoteDataSource(client: client),
        ),
      )(
        connectionId: widget.connection.connectionId,
        params: UpdateConnectionParams(
          clientId: _isNaturalPerson ? _identificationCtrl.text : _rucCtrl.text,
          connectionRateId: _rateName == 'BENEFICENCIA'
              ? 1
              : _rateName == 'RESIDENCIAL'
              ? 2
              : _rateName == 'INDUSTRIAL'
              ? 3
              : 6,
          connectionRateName: _rateName!,
          connectionMeterNumber: _meterNumberCtrl.text,
          connectionContractNumber: _contractNumberCtrl.text,
          connectionSewerage: _sewerage,
          connectionStatus: _status,
          connectionAddress: _connectionAddressCtrl.text,
          connectionInstallationDate: _installationDateCtrl.text.isNotEmpty
              ? _installationDateCtrl.text
              : DateTime.now().toIso8601String(),
          connectionPeopleNumber: int.tryParse(_peopleNumberCtrl.text) ?? 1,
          connectionZone: int.tryParse(_zoneCtrl.text) ?? 1,
          longitude: lng,
          latitude: lat,
          connectionReference: _referenceCtrl.text,
          propertyCadastralKey: _propertyCadastralKeyCtrl.text,
          connectionMetaData: {
            'country': _countryCtrl.text,
            'province': _provinceCtrl.text,
            'canton': _cantonCtrl.text,
            'full_address': _addressFullCtrl.text,
            'accuracy_meters': alt,
            'precision': prec,
            'source': 'mobile_app',
          },
          connectionAltitude: alt,
          connectionPrecision: prec,
          connectionGeolocationDate: _geolocationDateCtrl.text.isNotEmpty
              ? _geolocationDateCtrl.text
              : DateTime.now().toIso8601String(),
          zoneId: _zoneName == 'ZONA 1'
              ? 1
              : _zoneName == 'ZONA 2'
              ? 2
              : _zoneName == 'ZONA 3'
              ? 3
              : _zoneName == 'ZONA 4'
              ? 4
              : 0,
        ),
      );

      if (_observationDetailsCtrl.text.trim().isNotEmpty) {
        await AddObservationConnectionUseCase(
          ObservationConnectionRepositoryImpl(
            remoteDataSource: ObservationConnectionRemoteDataSource(
              client: client,
            ),
          ),
        )(
          params: CreateObservationParams(
            connectionId: _observationConnectionIdCtrl.text,
            observationTitle: _observationTitleCtrl.text,
            observationDetails: _observationDetailsCtrl.text,
          ),
        );
      }

      await UpdatePropertyUseCase(
        PropertyRepositoryImpl(
          remoteDataSource: PropertyRemoteDataSource(client: client),
        ),
      )(
        cadastralKey: _propertyCadastralKeyCtrl.text,
        params: UpdatePropertyParams(
          propertyClientId: _isNaturalPerson
              ? _identificationCtrl.text
              : _rucCtrl.text,
          propertyAlleyway: _alleywayCtrl.text,
          propertySector: _sectorCtrl.text,
          propertyAddress: _propertyAddressCtrl.text,
          propertyLandArea: double.tryParse(_landAreaCtrl.text) ?? 0.0,
          propertyConstructionArea:
              double.tryParse(_constructionAreaCtrl.text) ?? 0.0,
          propertyLandValue: double.tryParse(_landValueCtrl.text) ?? 0.0,
          propertyConstructionValue:
              double.tryParse(_constructionValueCtrl.text) ?? 0.0,
          propertyCommercialValue:
              (double.tryParse(_landValueCtrl.text) ?? 0.0) +
              (double.tryParse(_constructionValueCtrl.text) ?? 0.0),
          longitude: 0.0,
          latitude: 0.0,
          propertyReference: _referenceCtrl.text,
          propertyAltitude: 0.0,
          propertyPrecision: 0.0,
          propertyTypeId: 1,
        ),
      );

      _showSuccess();
    } catch (e) {
      _showSnackBar('Error al guardar: $e', error: true);
    } finally {
      client.close();
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: context.iconMedium),
          onPressed: _prevStep,
        ),
        title: Text(
          'Editar ${widget.connection.connectionId}',
          style: context.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCustomStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildClientStep(),
                _buildConnectionStep(),
                _buildPropertyStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Container(
      color: AppColors.shadow.withOpacity(0.8),
      padding: EdgeInsets.symmetric(vertical: context.smallSpacing * 1.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 35),
          _buildStepIcon(0, Icons.person),
          _buildStepConnector(1),
          _buildStepIcon(1, Icons.water_drop),
          _buildStepConnector(2),
          _buildStepIcon(2, Icons.home),
          const SizedBox(width: 35),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int index, IconData baseIcon) {
    final isActive = _currentStep == index;
    final isCompleted = _currentStep > index;
    final icon = isCompleted ? Icons.check : baseIcon;
    final bg = isActive
        ? AppColors.accent
        : isCompleted
        ? AppColors.secondary
        : AppColors.primary.withOpacity(0.3);
    final color = isActive ? Colors.white : Colors.white70;

    return GestureDetector(
      onTap: index <= _currentStep
          ? () {
              setState(() => _currentStep = index);
              _pageController.jumpToPage(index);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(icon, color: color, size: context.iconMedium),
      ),
    );
  }

  Widget _buildStepConnector(int nextIndex) {
    final isCompleted = _currentStep > nextIndex - 1;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        margin: EdgeInsets.symmetric(horizontal: context.smallSpacing),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildClientStep() {
    return SingleChildScrollView(
      padding: context.screenPadding,
      child: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            _buildSummaryCard(),
            context.vSpace(0.0),
            FormCard(
              title: 'Tipo de Cliente',
              child: Center(
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(
                        'Persona Natural',
                        style: TextStyle(
                          color: _isNaturalPerson
                              ? Colors.white
                              : AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      icon: Icon(
                        Icons.verified_user,
                        color: _isNaturalPerson
                            ? Colors.white
                            : AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(
                        'Empresa',
                        style: TextStyle(
                          color: _isCompany
                              ? Colors.white
                              : AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      icon: Icon(
                        Icons.business,
                        color: _isCompany
                            ? Colors.white
                            : AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                  ],
                  selected: {_isNaturalPerson},
                  onSelectionChanged: null,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? AppColors.primary
                          : AppColors.surface.withOpacity(0.6),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.mediumBorderRadiusValue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            context.vSpace(0.0),
            if (_isNaturalPerson)
              NaturalPersonForm(
                firstNameCtrl: _firstNameCtrl,
                lastNameCtrl: _lastNameCtrl,
                identificationCtrl: _identificationCtrl,
                dobCtrl: _dobCtrl,
                addressCtrl: _addressCtrl,
                emails: _emailsNatural,
                phones: _phonesNatural,
                onSelectDate: () => _selectDate(_dobCtrl),
              )
            else if (_isCompany)
              CompanyForm(
                companyNameCtrl: _companyNameCtrl,
                socialReasonCtrl: _socialReasonCtrl,
                rucCtrl: _rucCtrl,
                companyAddressCtrl: _companyAddressCtrl,
                emails: _emailsCompany,
                phones: _phonesCompany,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final clientName = widget.connection.person != null
        ? '${widget.connection.person!.firstName} ${widget.connection.person!.lastName}'
        : widget.connection.company?.businessName ?? 'Sin nombre';
    return FormCard(
      title: 'Información General',
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              _isCompany ? Icons.business : Icons.person,
              color: AppColors.primary,
              size: context.iconMedium,
            ),
          ),
          context.hSpace(0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.connection.connectionId,
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  clientName,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.connection.connectionAddress,
                  style: context.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStep() {
    return SingleChildScrollView(
      padding: context.screenPadding,
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            FormCard(
              title: 'Datos de la Acometida',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _cadastralKeyCtrl,
                          label: 'Clave Catastral',
                          icon: Icons.vpn_key,
                        ),
                      ),
                      context.hSpace(0.025),
                      Expanded(
                        child: CustomTextField(
                          controller: _meterNumberCtrl,
                          label: 'Número de Medidor',
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: TextEditingController(
                            text: formatFromIsoDate(_installationDateCtrl.text),
                          ),
                          label: 'Fecha de Instalación',
                          icon: Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _selectDate(_installationDateCtrl),
                        ),
                      ),
                      context.hSpace(0.025),
                      Expanded(
                        child: CustomTextField(
                          controller: _peopleNumberCtrl,
                          label: 'Número de Personas',
                          icon: Icons.group,
                          keyboardType: TextInputType.number,
                          validator: numberValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _validRates.contains(_rateName)
                              ? _rateName
                              : null,
                          hint: Text(
                            'Tarifa',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          decoration: _dropdownDecoration('Tarifa'),
                          isDense: true,
                          items: _validRates
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _rateName = v),
                        ),
                      ),
                      context.hSpace(0.02), // Espacio entre campos
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _validZones.contains(_zoneName)
                              ? _zoneName
                              : null,
                          hint: Text(
                            'Zona',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          decoration: _dropdownDecoration('Zona'),
                          isDense: true,
                          items: _validZones
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _zoneName = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _connectionAddressCtrl,
                    label: 'Dirección',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _referenceCtrl,
                    label: 'Referencia',
                    icon: Icons.pin_drop,
                    isRequired: false,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSwitchCard(
                        'Alcantarillado',
                        _sewerage,
                        (v) => setState(() => _sewerage = v),
                      ),
                      _buildSwitchCard(
                        'Estado Activo',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FormCard(
              title: 'Observación o Novedad',
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _observationDetailsCtrl,
                    label: 'Detalles',
                    icon: Icons.notes,
                    isTextArea: true,
                    isRequired: false,
                  ),
                ],
              ),
            ),
            ImagesSection(selectedImages: _selectedImages),
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
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 12, // Tamaño controlado
        color: Colors.grey[700],
        fontWeight: FontWeight.w400,
      ),
      hintStyle: TextStyle(fontSize: 10, color: Colors.grey[600]),
      filled: true,
      fillColor: AppColors.surface.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      isDense: true,
    );
  }

  Widget _buildPropertyStep() {
    return SingleChildScrollView(
      padding: context.screenPadding,
      child: Form(
        key: _formKeys[2],
        child: PropertyForm(
          cadastralKeyCtrl: _propertyCadastralKeyCtrl,
          propertyAddressCtrl: _propertyAddressCtrl,
          alleywayCtrl: _alleywayCtrl,
          landAreaCtrl: _landAreaCtrl,
          constructionAreaCtrl: _constructionAreaCtrl,
          landValueCtrl: _landValueCtrl,
          constructionValueCtrl: _constructionValueCtrl,
          properties: widget.connection.properties,
          onPropertySelected: (property) {
            setState(() {
              _propertyCadastralKeyCtrl.text = property.propertyCadastralKey;
              _propertyAddressCtrl.text = property.propertyAddress;
              _alleywayCtrl.text = property.propertyAlleyway;
              _landAreaCtrl.text = '';
              _constructionAreaCtrl.text = '';
              _landValueCtrl.text = '';
              _constructionValueCtrl.text = '';
            });
            _showSnackBar('Propiedad cargada: ${property.propertyAddress}');
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: context.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ActionButton(
                label: 'Anterior',
                icon: Icons.arrow_back,
                color: AppColors.textSecondary.withOpacity(0.8),
                onPressed: _prevStep,
              ),
            ),
          if (_currentStep > 0) context.hSpace(0.02),
          Expanded(
            child: ActionButton(
              label: _currentStep == 2 ? 'Finalizar' : 'Siguiente',
              icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
              color: AppColors.secondary,
              onPressed: _nextStep,
              loading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.smallSpacing * 0.5),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: context.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.smallSpacing,
          ),
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
          ),
        ),
      ),
    );
  }
}
