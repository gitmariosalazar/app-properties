import 'dart:io';
import 'package:app_properties/features/form/presentation/pages/form_screen.dart';
import 'package:app_properties/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart'; // ← AÑADIDO

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const accent = Color(0xFFFFC107);
  static const error = Color(0xFFE57373);
  static const background = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const surface = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const border = Color(0xFFBDBDBD);
  static const disabled = Color(0xFF9E9E9E);
  static const highlight = Color(0xFFBBDEFB);
  static const shadow = Color(0x29000000);
}

class UpdateFormScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const UpdateFormScreen({super.key, required this.data});

  @override
  State<UpdateFormScreen> createState() => _UpdateFormScreenState();
}

class _UpdateFormScreenState extends State<UpdateFormScreen>
    with TickerProviderStateMixin {
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _isNaturalPerson = true;
  bool _isSubmitting = false;
  bool _isDatePickerActive = false;
  bool _isGettingLocation = false;

  GoogleMapController? _mapController;

  // === Cliente Natural ===
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _identificationCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final List<TextEditingController> _emailsNatural = [];
  final List<TextEditingController> _phonesNatural = [];

  // === Empresa ===
  final _companyNameCtrl = TextEditingController();
  final _socialReasonCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();
  final List<TextEditingController> _emailsCompany = [];
  final List<TextEditingController> _phonesCompany = [];

  // === Acometida ===
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
  String _rateName = 'COMERCIAL';
  bool _sewerage = true;
  bool _status = true;

  // === Predio ===
  final _cadastralKeyCtrl = TextEditingController();
  final _propertyAddressCtrl = TextEditingController();
  final _alleywayCtrl = TextEditingController();
  final _landAreaCtrl = TextEditingController();
  final _constructionAreaCtrl = TextEditingController();
  final _landValueCtrl = TextEditingController();
  final _constructionValueCtrl = TextEditingController();

  // === NUEVOS CAMPOS: GEOCODING ===
  final _countryCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cantonCtrl = TextEditingController();
  final _addressFullCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();

  // === NUEVO: IMÁGENES ===
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _animationController.forward();
    });

    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _loadInitialData() {
    final data = widget.data;
    if (data.isEmpty) return;

    final clientName = data['clientName']?.toString() ?? '';
    final nameParts = clientName.split(' ');
    _firstNameCtrl.text = nameParts.isNotEmpty ? nameParts.first : '';
    _lastNameCtrl.text = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';
    _identificationCtrl.text = data['clientId']?.toString() ?? '';
    _addressCtrl.text = data['clientAddress']?.toString() ?? '';

    _meterNumberCtrl.text = data['connectionMeterNumber']?.toString() ?? '';
    _contractNumberCtrl.text =
        data['connectionContractNumber']?.toString() ?? '';
    _connectionAddressCtrl.text = data['connectionAddress']?.toString() ?? '';
    _installationDateCtrl.text =
        data['connectionInstallationDate']?.toString() ?? '';
    _peopleNumberCtrl.text = data['connectionPeopleNumber']?.toString() ?? '4';
    _referenceCtrl.text = data['connectionReference']?.toString() ?? '';
    _latitudeCtrl.text =
        data['latitude']?.toString() ??
        data['connectionCoordinates']?.toString().split(',')?.first ??
        '-0.180653';
    _longitudeCtrl.text =
        data['longitude']?.toString() ??
        data['connectionCoordinates']?.toString().split(',')?.last ??
        '-78.467834';
    _sectorCtrl.text = data['connectionSector']?.toString() ?? '';
    _accountCtrl.text = data['connectionAccount']?.toString() ?? '';
    _zoneCtrl.text = data['connectionZone']?.toString() ?? '';
    _rateName = data['connectionRateName']?.toString() ?? 'COMERCIAL';
    _sewerage = data['connectionSewerage'] as bool? ?? true;
    _status = data['connectionStatus'] as bool? ?? true;

    _cadastralKeyCtrl.text = data['connectionCadastralKey']?.toString() ?? '';
    _propertyAddressCtrl.text =
        data['propertyAddress']?.toString() ??
        data['connectionAddress']?.toString() ??
        '';
    _alleywayCtrl.text =
        data['propertyAlleyway']?.toString() ?? 'Calle Principal';
    _landAreaCtrl.text = data['propertyLandArea']?.toString() ?? '500';
    _constructionAreaCtrl.text =
        data['propertyConstructionArea']?.toString() ?? '300';
    _landValueCtrl.text = data['propertyLandValue']?.toString() ?? '100000';
    _constructionValueCtrl.text =
        data['propertyConstructionValue']?.toString() ?? '150000';

    if (_emailsNatural.isEmpty)
      _emailsNatural.add(TextEditingController(text: 'cliente@ejemplo.com'));
    if (_phonesNatural.isEmpty)
      _phonesNatural.add(TextEditingController(text: '+593999999999'));
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email requerido';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim()))
      return 'Email inválido';
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Teléfono requerido';
    if (value.trim().length < 10) return 'Teléfono inválido (mín 10 dígitos)';
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Número requerido';
    if (double.tryParse(value.trim()) == null) return 'Número inválido';
    return null;
  }

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

  // === OBTENER UBICACIÓN + GEOCODING ===
  Future<void> _getCurrentLocationAndAddress() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar(
          'El servicio de ubicación está desactivado.',
          error: true,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Permiso de ubicación denegado.', error: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          'Permiso de ubicación denegado permanentemente.',
          error: true,
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeCtrl.text = position.latitude.toStringAsFixed(8);
        _longitudeCtrl.text = position.longitude.toStringAsFixed(8);
        _accuracyCtrl.text = position.accuracy.toStringAsFixed(1);
      });

      await _reverseGeocode(position.latitude, position.longitude);

      _showSnackBar('Ubicación y dirección obtenidas.');

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }
    } catch (e) {
      _showSnackBar('Error al obtener ubicación: $e', error: true);
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  // === GEOCODING INVERSO ===
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

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
      _showSnackBar('Error al obtener dirección: $e', error: true);
    }
  }

  // === MAPA CON MARCADOR ARRASTRABLE ===
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
            });
            await _reverseGeocode(lat, lng);
          },
        ),
      ),
    );
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

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Guardado', style: context.titleMedium),
        content: Text(
          '¿Desea guardar todos los cambios realizados?',
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

    if (confirmed == true) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isSubmitting = false);
      _showSuccess();
    }
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

  @override
  Widget build(BuildContext context) {
    final connectionId = widget.data['connectionId']?.toString() ?? 'Datos';
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
          tooltip: 'Regresar',
        ),
        title: Text(
          'Editar $connectionId',
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
          Container(
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
                    child: _ActionButton(
                      label: 'Anterior',
                      icon: Icons.arrow_back,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      onPressed: _prevStep,
                    ),
                  ),
                if (_currentStep > 0) context.hSpace(0.02),
                Expanded(
                  child: _ActionButton(
                    label: _currentStep == 2 ? 'Finalizar' : 'Siguiente',
                    icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                    color: AppColors.secondary,
                    onPressed: _nextStep,
                    loading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ),
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
    final iconToShow = isCompleted ? Icons.check : baseIcon;
    final bgColor = isActive
        ? AppColors.accent
        : isCompleted
        ? AppColors.secondary
        : AppColors.primary.withOpacity(0.3);
    final iconColor = isActive ? Colors.white : Colors.white70;

    return GestureDetector(
      onTap: index <= _currentStep
          ? () {
              setState(() => _currentStep = index);
              _pageController.jumpToPage(index);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 35,
        height: 35,
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
          gradient: isActive
              ? const RadialGradient(
                  colors: [AppColors.accent, AppColors.accent],
                )
              : null,
          color: bgColor,
        ),
        child: Icon(iconToShow, color: iconColor, size: context.iconMedium),
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
            _buildCard(
              title: 'Tipo de Cliente',
              child: Center(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Persona Natural'),
                      icon: Icon(Icons.person),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Empresa'),
                      icon: Icon(Icons.business),
                    ),
                  ],
                  selected: {_isNaturalPerson},
                  onSelectionChanged: (s) =>
                      setState(() => _isNaturalPerson = s.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? AppColors.primary
                          : Colors.grey[200],
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? Colors.white
                          : AppColors.textPrimary,
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
              ..._buildNaturalPersonForm()
            else
              ..._buildCompanyForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      title: 'Información General',
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.business_center,
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
                  widget.data['connectionId']?.toString() ?? 'N/A',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  widget.data['clientName']?.toString() ?? 'Sin nombre',
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.data['connectionAddress']?.toString() ??
                      'Sin dirección',
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

  List<Widget> _buildNaturalPersonForm() => [
    _buildCard(
      title: 'Datos Personales',
      child: Column(
        children: [
          _textField(_firstNameCtrl, 'Nombres', Icons.person_outline),
          _textField(_lastNameCtrl, 'Apellidos', Icons.person),
          _textField(_addressCtrl, 'Dirección', Icons.home),
          Row(
            children: [
              Expanded(
                child: _textField(
                  _identificationCtrl,
                  'Cédula / Pasaporte',
                  Icons.badge,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
              ),
              context.hSpace(0.05),
              Expanded(
                child: _textField(
                  _dobCtrl,
                  'Fecha de Nacimiento',
                  Icons.cake,
                  readOnly: true,
                  onTap: () => _selectDate(_dobCtrl),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    context.vSpace(0.0),
    _buildDynamicList(
      title: 'Correos Electrónicos',
      controllers: _emailsNatural,
      hint: 'email@dominio.com',
      icon: Icons.email,
    ),
    context.vSpace(0.0),
    _buildDynamicList(
      title: 'Teléfonos',
      controllers: _phonesNatural,
      hint: '+593 99 999 9999',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
    ),
  ];

  List<Widget> _buildCompanyForm() => [
    _buildCard(
      title: 'Datos de la Empresa',
      child: Column(
        children: [
          _textField(_companyNameCtrl, 'Razón Social', Icons.business),
          _textField(_socialReasonCtrl, 'Nombre Comercial', Icons.store),
          _textField(
            _rucCtrl,
            'RUC',
            Icons.credit_card,
            keyboardType: TextInputType.number,
            validator: _numberValidator,
          ),
          _textField(_companyAddressCtrl, 'Dirección', Icons.location_on),
        ],
      ),
    ),
    context.vSpace(0.0),
    _buildDynamicList(
      title: 'Correos de la Empresa',
      controllers: _emailsCompany,
      hint: 'info@empresa.com',
      icon: Icons.email,
    ),
    context.vSpace(0.0),
    _buildDynamicList(
      title: 'Teléfonos de la Empresa',
      controllers: _phonesCompany,
      hint: '+593 2 123 4567',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
    ),
  ];

  Widget _buildConnectionStep() {
    return SingleChildScrollView(
      padding: context.screenPadding,
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            _buildCard(
              title: 'Datos de la Acometida',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          _cadastralKeyCtrl,
                          'Clave Catastral',
                          Icons.vpn_key,
                        ),
                      ),
                      context.hSpace(0.015),
                      Expanded(
                        child: _textField(
                          _meterNumberCtrl,
                          'Número de Medidor',
                          Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          TextEditingController(
                            text: formatFromIsoDate(_installationDateCtrl.text),
                          ),
                          'Fecha de Instalación',
                          Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _selectDate(_installationDateCtrl),
                        ),
                      ),
                      context.hSpace(0.015),
                      Expanded(
                        child: _textField(
                          _contractNumberCtrl,
                          'Número de Contrato',
                          Icons.description,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === DROPDOWN SIN OVERFLOW ===
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: DropdownButtonFormField<String>(
                            value: _rateName,
                            isDense: true,
                            decoration: InputDecoration(
                              labelText: 'Tarifa',
                              labelStyle: context.bodyLarge,
                              prefixIcon: Icon(
                                Icons.category,
                                color: AppColors.primary,
                                size: context.iconSmall,
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: AppColors.surface.withOpacity(0.3),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: context.mediumSpacing * 0.5,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  context.smallBorderRadiusValue,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  context.smallBorderRadiusValue,
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                              ),
                            ),
                            items: ['RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL']
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r,
                                      style: context.bodyMedium.copyWith(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _rateName = v!),
                            style: context.bodyMedium,
                            dropdownColor: AppColors.card,
                          ),
                        ),
                      ),

                      const SizedBox(width: 3),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: _textField(
                            _peopleNumberCtrl,
                            'Número de Personas',
                            Icons.group,
                            keyboardType: TextInputType.number,
                            validator: _numberValidator,
                          ),
                        ),
                      ),
                    ],
                  ),

                  _textField(
                    _connectionAddressCtrl,
                    'Dirección',
                    Icons.location_on,
                  ),

                  _textField(_referenceCtrl, 'Referencia', Icons.pin_drop),

                  Row(
                    children: [
                      _buildSwitchCard(
                        title: 'Alcantarillado',
                        value: _sewerage,
                        onChanged: (v) => setState(() => _sewerage = v),
                        margin: EdgeInsets.only(
                          right: context.smallSpacing * 0.5,
                        ),
                      ),
                      _buildSwitchCard(
                        title: 'Estado Activo',
                        value: _status,
                        onChanged: (v) => setState(() => _status = v),
                        margin: EdgeInsets.only(
                          left: context.smallSpacing * 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            context.vSpace(0.0),
            _buildImagesSection(),
            _buildGpsCard(),
          ],
        ),
      ),
    );
  }

  // === NUEVO: SECCIÓN DE IMÁGENES ===
  Widget _buildImagesSection() {
    final double imageSize = context.isTablet ? 90.0 : 55.0;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                    size: context.iconSmall,
                  ),
                  context.hSpace(0.01),
                  Text(
                    'Fotos de Referencia',
                    style: context.titleExtraSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          context.vSpace(0.01),
          SizedBox(
            height: imageSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              separatorBuilder: (_, __) =>
                  SizedBox(width: context.smallSpacing),
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return _buildAddImageButton(imageSize);
                } else {
                  final file = File(_selectedImages[index].path);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          file,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.error.withOpacity(0.3),
                              child: Center(
                                child: Text(
                                  'Error',
                                  style: context.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (!mounted) return;
                            setState(() => _selectedImages.removeAt(index));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // === NUEVO: BOTÓN PARA AGREGAR IMAGEN ===
  Widget _buildAddImageButton(double size) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedImage != null && mounted) {
          setState(() {
            _selectedImages.add(pickedImage);
          });
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface.withOpacity(0.75),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.45),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add_a_photo_rounded,
          size: size * 0.48,
          color: AppColors.primary.withOpacity(0.82),
        ),
      ),
    );
  }

  Widget _buildGpsCard() {
    return _buildCard(
      title: 'Ubicación GPS',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  _latitudeCtrl,
                  'Latitud',
                  Icons.north,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _numberValidator,
                ),
              ),
              context.hSpace(0.01),
              Expanded(
                child: _textField(
                  _longitudeCtrl,
                  'Longitud',
                  Icons.east,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _numberValidator,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _textField(
                  _accuracyCtrl,
                  'Precisión (m)',
                  Icons.gps_fixed,
                  readOnly: true,
                ),
              ),
              context.hSpace(0.01),
              Expanded(
                child: _textField(
                  _countryCtrl,
                  'País',
                  Icons.flag,
                  readOnly: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _textField(
                  _provinceCtrl,
                  'Provincia',
                  Icons.map,
                  readOnly: true,
                ),
              ),
              context.hSpace(0.01),
              Expanded(
                child: _textField(
                  _cantonCtrl,
                  'Cantón',
                  Icons.location_city,
                  readOnly: true,
                ),
              ),
            ],
          ),
          _textField(
            _addressFullCtrl,
            'Dirección Completa',
            Icons.home,
            readOnly: true,
          ),
          Row(
            children: [
              Expanded(
                child: ResponsiveButton(
                  label: 'Obtener Todo',
                  icon: Icons.my_location,
                  color: AppColors.secondary,
                  height: context.mediumSpacing * 5,
                  animationController: _animationController,
                  scaleAnimation: _scaleAnimation,
                  onPressed: _getCurrentLocationAndAddress,
                  loading: _isGettingLocation,
                ),
              ),
              context.hSpace(0.02),
              Expanded(
                child: ResponsiveButton(
                  label: 'Ver en Mapa',
                  icon: Icons.map,
                  color: AppColors.primary,
                  onPressed: _openMap,
                  height: context.mediumSpacing * 5,
                  animationController: _animationController,
                  scaleAnimation: _scaleAnimation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStep() {
    return SingleChildScrollView(
      padding: context.screenPadding,
      child: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            _buildCard(
              title: 'Datos del Predio',
              child: Column(
                children: [
                  _textField(_cadastralKeyCtrl, 'Clave Catastral', Icons.key),
                  _textField(_propertyAddressCtrl, 'Dirección', Icons.home),
                  _textField(_alleywayCtrl, 'Callejón', Icons.streetview),
                ],
              ),
            ),
            context.vSpace(0.0),
            _buildCard(
              title: 'Áreas y Avalúos',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          _landAreaCtrl,
                          'Área Terreno (m²)',
                          Icons.landscape,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                      ),
                      context.hSpace(0.01),
                      Expanded(
                        child: _textField(
                          _constructionAreaCtrl,
                          'Área Construcción (m²)',
                          Icons.home_repair_service,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          _landValueCtrl,
                          'Valor Terreno',
                          Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                      ),
                      context.hSpace(0.01),
                      Expanded(
                        child: _textField(
                          _constructionValueCtrl,
                          'Valor Construcción',
                          Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({String? title, required Widget child}) {
    return Card(
      elevation: context.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.cardBorderRadiusValue),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: context.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: context.smallSpacing * 2.2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.cardBorderRadiusValue - 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: context.iconSmall,
                    ),
                    context.hSpace(0.015),
                    Text(
                      title,
                      style: context.titleExtraSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.largeSpacing),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        inputFormatters:
            keyboardType == TextInputType.number ||
                keyboardType ==
                    const TextInputType.numberWithOptions(decimal: true)
            ? [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: context.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: context.iconSmall,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: readOnly
              ? AppColors.surface.withOpacity(0.2)
              : AppColors.surface.withOpacity(0.4),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.mediumSpacing,
            vertical: context.smallSpacing,
          ),
          isDense: true,
        ),
        style: context.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        validator:
            validator ??
            (v) => v?.trim().isEmpty == true ? 'Campo requerido' : null,
      ),
    );
  }

  Widget _buildDynamicList({
    required String title,
    required List<TextEditingController> controllers,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    if (controllers.isEmpty) controllers.add(TextEditingController());

    String? Function(String?)? getValidator() {
      final lower = title.toLowerCase();
      if (lower.contains('corre') || lower.contains('email'))
        return _emailValidator;
      if (lower.contains('teléfon') || lower.contains('phone'))
        return _phoneValidator;
      return null;
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: context.iconSmall,
                  ),
                  context.hSpace(0.01),
                  Text(
                    title,
                    style: context.titleExtraSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              _CompactAddButton(
                onPressed: () =>
                    setState(() => controllers.add(TextEditingController())),
              ),
            ],
          ),
          context.vSpace(0.015),
          ...controllers.asMap().entries.map((e) {
            final index = e.key;
            final ctrl = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: context.smallSpacing * 0.8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextFormField(
                        controller: ctrl,
                        keyboardType: keyboardType,
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: context.bodySmall.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(icon, size: context.iconSmall),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              context.smallBorderRadiusValue,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.mediumSpacing,
                            vertical: 0,
                          ),
                          isDense: true,
                        ),
                        style: context.bodyMedium,
                        validator: getValidator(),
                      ),
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: AppColors.error,
                        size: context.iconMedium,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        padding: EdgeInsets.all(context.smallSpacing * 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () =>
                          setState(() => controllers.removeAt(index)),
                      tooltip: 'Eliminar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required EdgeInsetsGeometry margin,
  }) {
    return Expanded(
      child: Container(
        margin: margin,
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

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _mapController?.dispose();
    _selectedImages.clear(); // ← LIMPIAR IMÁGENES
    [
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
      _cadastralKeyCtrl,
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
    ].forEach((c) => c.dispose());
    super.dispose();
  }
}

// === PANTALLA DE MAPA CON MARCADOR ARRASTRABLE ===
class MapPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Function(double lat, double lng) onLocationPicked;

  const MapPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onLocationPicked,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  late CameraPosition _cameraPosition;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
      target: LatLng(widget.initialLat, widget.initialLng),
      zoom: 17,
    );
    _marker = Marker(
      markerId: const MarkerId('picked_location'),
      position: LatLng(widget.initialLat, widget.initialLng),
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Seleccionar Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final pos = _marker.position;
              widget.onLocationPicked(pos.latitude, pos.longitude);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _cameraPosition,
        onMapCreated: (controller) => _controller = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {_marker},
        onTap: (latLng) {
          setState(() {
            _marker = _marker.copyWith(positionParam: latLng);
          });
          _controller?.animateCamera(CameraUpdate.newLatLng(latLng));
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () async {
          try {
            final position = await Geolocator.getCurrentPosition();
            final newPos = LatLng(position.latitude, position.longitude);
            setState(() {
              _marker = _marker.copyWith(positionParam: newPos);
            });
            _controller?.animateCamera(CameraUpdate.newLatLng(newPos));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al obtener ubicación: $e')),
            );
          }
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool loading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      label: Text(label),
      icon: Icon(icon, size: context.iconSmall),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: context.buttonBorderRadiusValue,
        ),
      ),
    );
  }
}

class _CompactAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CompactAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.add_circle_outline,
        color: AppColors.secondary,
        size: context.iconExtraSmall,
      ),
      label: Text(
        'Agregar otro',
        style: context.bodySmall.copyWith(
          color: AppColors.secondary,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.secondary.withOpacity(0.1),
        padding: EdgeInsets.symmetric(
          horizontal: context.smallSpacing * 0.9,
          vertical: context.extraSmallSpacing * 0.7,
        ),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
        ),
      ),
    );
  }
}
