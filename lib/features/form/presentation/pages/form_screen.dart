import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_properties/components/card/title_card.dart';
import 'package:app_properties/components/divider/section_divider.dart';
import 'package:app_properties/components/text/edit_text_field.dart';
import 'package:app_properties/components/text/read_only_field.dart';
import 'package:app_properties/features/form/presentation/services/photo_reading_service.dart';
import 'package:app_properties/utils/consumption_utils.dart';
import 'package:app_properties/utils/date_utils.dart';
import 'package:app_properties/utils/dialog_utils.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/utils/screen_type_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:image_picker/image_picker.dart';
import 'package:app_properties/components/button/widget_button.dart';
import 'package:go_router/go_router.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const cardSecondaryBackground = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class FormScreen extends StatefulWidget {
  final Map<String, dynamic> apiResponse;
  final String mode; // 'scan' or 'manual'

  const FormScreen({super.key, required this.apiResponse, required this.mode});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<File> _attachedImages = [];
  final _connectionIdController = TextEditingController();
  final _connectionOwnerController = TextEditingController();
  final _readingIdController = TextEditingController();
  final _cardIdController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _previousReadingController = TextEditingController();
  final _sectorConnectionController = TextEditingController();
  final _addressConnectionController = TextEditingController();
  final _accountConnectionController = TextEditingController();
  final _cadastralKeyConnectionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _averageConsumptionController = TextEditingController();
  final _currentConsumptionController = TextEditingController();
  final _previousConsumptionController = TextEditingController();
  final _readingValueController = TextEditingController();
  final _previousReadingDate = TextEditingController();
  final _newCurrentReadingController = TextEditingController();
  final _now = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConsumptionVisuals _consumptionVisuals;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupListeners();
    _setupAnimations();
  }

  void _initializeData() {
    final List<dynamic> dataList = [];
    Map<String, dynamic> data = {};
    if (widget.apiResponse.containsKey('apiResponse') &&
        widget.apiResponse['apiResponse'] is Map<String, dynamic> &&
        widget.apiResponse['apiResponse'].containsKey('data') &&
        widget.apiResponse['apiResponse']['data'] is List) {
      dataList.addAll(
        widget.apiResponse['apiResponse']['data'] as List<dynamic>,
      );
    } else if (widget.apiResponse.containsKey('data') &&
        widget.apiResponse['data'] is List) {
      dataList.addAll(widget.apiResponse['data'] as List<dynamic>);
    } else {
      data = widget.apiResponse;
    }
    if (dataList.isNotEmpty) data = dataList.first as Map<String, dynamic>;
    _connectionIdController.text = data['cadastralKey']?.toString() ?? '';
    _connectionOwnerController.text = data['clientName']?.toString() ?? '';
    _readingIdController.text = data['readingId']?.toString() ?? '';
    _cardIdController.text = data['cardId']?.toString() ?? '';
    _currentReadingController.text = data['currentReading']?.toString() ?? '';
    _previousReadingController.text = data['previousReading']?.toString() ?? '';
    _sectorConnectionController.text = data['sector']?.toString() ?? '';
    _addressConnectionController.text = data['address']?.toString() ?? '';
    _accountConnectionController.text = data['account']?.toString() ?? '';
    _cadastralKeyConnectionController.text =
        data['cadastralKey']?.toString() ?? '';
    _descriptionController.text = '';
    _averageConsumptionController.text =
        data['averageConsumption']?.toString() ?? '';
    _readingValueController.text = data['readingValue']?.toString() ?? '';
    _previousReadingDate.text = data['previousReadingDate']?.toString() ?? '';
    _newCurrentReadingController.text = '';
    _currentConsumptionController.text = ConsumptionUtils.calculateConsumption(
      _newCurrentReadingController.text,
      _currentReadingController.text,
    );
    _previousConsumptionController.text = ConsumptionUtils.calculateConsumption(
      _currentReadingController.text,
      _previousReadingController.text,
    );
    _updateConsumptionVisuals();
  }

  void _setupListeners() {
    _newCurrentReadingController.addListener(_updateCurrentConsumption);
    _previousReadingController.addListener(_updateCurrentConsumption);
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

  void _updateCurrentConsumption() {
    final value = ConsumptionUtils.calculateConsumption(
      _newCurrentReadingController.text,
      _currentReadingController.text,
    );
    _currentConsumptionController.text = value;
    _updateConsumptionVisuals();
    if (mounted) setState(() {});
  }

  void _updateConsumptionVisuals() {
    _consumptionVisuals = ConsumptionUtils.setConsumptionVisuals(
      currentConsumption: double.tryParse(_currentConsumptionController.text),
      averageConsumption: double.tryParse(_averageConsumptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Detalle de La Acometida',
            style: ResponsiveUtils.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: ResponsiveUtils.cardElevation(context),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.05),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: ResponsiveUtils.screenPadding(context).copyWith(
              top: ResponsiveUtils.scaleHeight(context, 0.035),
              bottom: ResponsiveUtils.scaleHeight(context, 0.025),
            ),
            child: BlocConsumer<form_bloc.FormBloc, form_bloc.FormState>(
              listener: (context, state) {
                if (!mounted) return;
                if (state is form_bloc.FormSuccess) {
                  _handleSuccess(context, state);
                } else if (state is form_bloc.FormFailure) {
                  setState(() => _errorMessage = state.message);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderRow(context),
                        ResponsiveUtils.vSpace(context, 0.03),
                        _buildConsumptionRow(context, state),
                        ResponsiveUtils.vSpace(context, 0.03),
                        _buildReadingFieldsRow(),
                        ResponsiveUtils.vSpace(context, 0.015),
                        _buildDescriptionField(context),
                        ResponsiveUtils.vSpace(context, 0.015),
                        _buildImagesSection(context),
                        if (_errorMessage != null || _successMessage != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: ResponsiveUtils.scaleHeight(context, 0.01),
                              left: ResponsiveUtils.scaleWidth(context, 0.03),
                              right: ResponsiveUtils.scaleWidth(context, 0.03),
                            ),
                            child: Text(
                              _errorMessage ?? _successMessage ?? "",
                              style: ResponsiveUtils.bodySmall(context)
                                  .copyWith(
                                    color: _errorMessage != null
                                        ? AppColors.error
                                        : AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ResponsiveUtils.vSpace(context, 0.02),
                        _buildActionButtonsRow(context, state),
                        ResponsiveUtils.vSpace(context, 0.03),
                        MinimalSectionDivider(
                          title: 'Información Adicional',
                          color: AppColors.primary.withOpacity(0.8),
                          children: [
                            ResponsiveUtils.vSpace(context, 0.015),
                            _buildIdFieldsRow(),
                            ResponsiveUtils.vSpace(context, 0.03),
                            _buildOwnerAddressFields(),
                            ResponsiveUtils.vSpace(context, 0.03),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleSuccess(BuildContext context, form_bloc.FormSuccess state) async {
    DialogUtils.showResultDialog(
      context,
      '¡Formulario enviado con éxito!',
      Icons.check_circle,
      AppColors.secondary,
    );
    if (_attachedImages.isNotEmpty) {
      debugPrint('Iniciando subida de imágenes...');
      debugPrint('Número de imágenes a subir: ${_attachedImages.length}');
      /*Print Datos a Enviar*/
      debugPrint('Datos a enviar:');
      debugPrint('Reading ID: ${state.data['readingId']}');
      debugPrint('Cadastral Key: ${state.data['cadastralKey']}');

      try {
        await submitPhotoReading(
          context: context,
          images: _attachedImages,
          readingId: state.data['readingId'],
          cadastralKey: state.data['cadastralKey'],
          description: state.data['novelty'] ?? 'Sin descripción',
          mode: widget.mode,
        );
        if (!mounted) return;
        setState(() {
          _attachedImages.clear();
          _successMessage = 'Imágenes subidas con éxito.';
          _errorMessage = null;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _errorMessage = 'Error al subir imágenes: $e');
      }
    } else {
      debugPrint('No hay imágenes para subir.');
    }
  }

  Widget _buildImagesSection(BuildContext context) {
    final double imageSize = ResponsiveUtils.isTablet(context) ? 90.0 : 55.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargar Imágenes',
          style: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        ResponsiveUtils.vSpace(context, 0.01),
        SizedBox(
          height: imageSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _attachedImages.length + 1,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveUtils.smallSpacing(context)),
            itemBuilder: (context, index) {
              if (index == _attachedImages.length) {
                return _buildAddImageButton(context, imageSize);
              } else {
                final file = _attachedImages[index];
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
                                'Error al cargar imagen',
                                style: ResponsiveUtils.bodySmall(
                                  context,
                                ).copyWith(color: AppColors.error),
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
                          setState(() => _attachedImages.removeAt(index));
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
    );
  }

  Widget _buildAddImageButton(BuildContext context, double size) {
    return GestureDetector(
      onTap: () async {
        if (!mounted) return;
        final picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedImage != null && mounted) {
          setState(() {
            _attachedImages.add(File(pickedImage.path));
            if (widget.mode == 'manual' && _attachedImages.length >= 1) {
              _errorMessage = null;
            }
          });
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.cardSecondaryBackground.withOpacity(0.75),
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

  Widget _buildHeaderRow(BuildContext context) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Conexión ID',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.cable,
            color: AppColors.secondary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground,
          children: [
            Text(
              _connectionIdController.text.isEmpty
                  ? 'Sin ID de conexión'
                  : _connectionIdController.text,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        TitledCard(
          title: 'Consumo Prom.',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.water_drop,
            color: AppColors.primary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground,
          children: [
            Text(
              _connectionIdController.text.isEmpty
                  ? '0.0 m³'
                  : '${double.tryParse(_averageConsumptionController.text)?.toStringAsFixed(2) ?? '0.00'} m³',
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsumptionRow(BuildContext context, form_bloc.FormState state) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Consumo Anterior',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.history,
            color: AppColors.textSecondary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardSecondaryBackground,
          children: [_buildConsumptionCardContent(context, isPrevious: true)],
        ),
        TitledCard(
          title: 'Consumo Actual',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            _consumptionVisuals.icon,
            color: _consumptionVisuals.textColor,
            size: ResponsiveUtils.iconSmall(context),
          ),
          backgroundColor: _consumptionVisuals.backgroundColor,
          titleStyle: ResponsiveUtils.titleSmall(context),
          children: [_buildConsumptionCardContent(context, isPrevious: false)],
        ),
      ],
    );
  }

  Widget _buildConsumptionCardContent(
    BuildContext context, {
    required bool isPrevious,
    TextStyle? textStyle,
  }) {
    final style = textStyle ?? ResponsiveUtils.titleMedium(context);
    final controller = isPrevious
        ? _previousConsumptionController
        : _currentConsumptionController;
    final dateText = isPrevious
        ? (_previousReadingDate.text.isEmpty
              ? 'N/A'
              : formatFromIsoDate(_previousReadingDate.text))
        : formatDate(_now);
    final bgColor = isPrevious
        ? AppColors.cardSecondaryBackground
        : _consumptionVisuals.backgroundColor;
    final textColor = isPrevious
        ? AppColors.textPrimary
        : _consumptionVisuals.textColor;
    final dateTextColor = isPrevious
        ? AppColors.textSecondary
        : _consumptionVisuals.textColor.withOpacity(0.8);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.cardBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: ResponsiveUtils.cardPadding(context),
          child: Text(
            controller.text.isEmpty ? '0.0 m³' : '${controller.text} m³',
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ResponsiveUtils.vSpace(context, 0.015),
        Text(
          'Fecha: $dateText',
          style: ResponsiveUtils.bodySmall(
            context,
          ).copyWith(color: dateTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIdFieldsRow() {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        ReadOnlyField(
          controller: _cardIdController,
          label: 'Cédula de Ciudadanía',
          leftIcon: Icons.pin,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        ReadOnlyField(
          controller: _readingIdController,
          label: 'ID de Lectura',
          leftIcon: Icons.water_damage_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildOwnerAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReadOnlyField(
          controller: _connectionOwnerController,
          label: 'Propietario de la Conexión',
          leftIcon: Icons.person_outline,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        ResponsiveUtils.vSpace(context, 0.03),
        ReadOnlyField(
          controller: _addressConnectionController,
          label: 'Dirección de la Conexión',
          leftIcon: Icons.location_on_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildReadingFieldsRow() {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(
          controller: _currentReadingController,
          label: 'Lectura Anterior',
          leftIcon: Icons.history_outlined,
          textStyle: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        EditTextField(
          controller: _newCurrentReadingController,
          label: 'Lectura Actual (Obligatorio)',
          leftIcon: Icons.speed_outlined,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Por favor, ingrese la lectura actual';
            final number = double.tryParse(value);
            if (number == null || number < 0)
              return 'Ingrese un número positivo válido';
            return null;
          },
          textStyle: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return EditTextField(
      controller: _descriptionController,
      label:
          'Descripción o Novedades${widget.mode == 'manual' ? ' (Requerido)' : ' (Opcional)'}',
      leftIcon: Icons.description,
      maxLines: ResponsiveUtils.isTablet(context) ? 5 : 3,
      hintText: widget.mode == 'manual'
          ? 'Ingrese una descripción detallada...'
          : 'Ingrese una descripción o novedad...',
      textStyle: ResponsiveUtils.bodyMedium(
        context,
      ).copyWith(color: AppColors.textPrimary),
      validator: widget.mode == 'manual'
          ? (value) {
              if (value == null || value.isEmpty)
                return 'Por favor, ingrese una descripción';
              return null;
            }
          : null,
    );
  }

  Widget _buildActionButtonsRow(
    BuildContext context,
    form_bloc.FormState state,
  ) {
    return ResponsiveRow(
      forceRow: true,
      rowSpacing: ResponsiveUtils.largeSpacing(context),
      children: [
        ResponsiveButton(
          onPressed: state is form_bloc.FormLoading
              ? null
              : () => _onSavePressed(context, state),
          icon: Icons.save,
          label: 'Guardar',
          color: AppColors.secondary,
          loading: state is form_bloc.FormLoading,
          height: ResponsiveUtils.buttonSmall(context),
          animationController: _animationController,
          scaleAnimation: _scaleAnimation,
        ),
        ResponsiveButton(
          onPressed: state is form_bloc.FormLoading
              ? null
              : () => context.pop(),
          icon: Icons.cancel,
          label: 'Cancelar',
          color: AppColors.error,
          loading: false,
          height: ResponsiveUtils.buttonSmall(context),
          animationController: _animationController,
          scaleAnimation: _scaleAnimation,
        ),
        ActionButton(
          icon: Icons.location_on_outlined,
          circular: true,
          onPressed: () {
            context.push('/location');
          },
        ),
      ],
    );
  }

  Future<void> _onSavePressed(
    BuildContext context,
    form_bloc.FormState state,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.mode == 'manual' && _attachedImages.isEmpty) {
      if (mounted) {
        setState(
          () =>
              _errorMessage = 'Se requiere al menos una imagen en modo manual.',
        );
      }
      return;
    }
    setState(() => _errorMessage = null);

    final confirmed = await DialogUtils.showConfirmationDialog(
      context,
      onConfirm: () {
        if (!mounted) return;
        context.read<form_bloc.FormBloc>().add(
          form_bloc.InsertReadingEvent(
            novelty: _descriptionController.text,
            currentReading: double.parse(_newCurrentReadingController.text),
            previousReading: double.parse(
              _currentReadingController.text.isEmpty
                  ? '0'
                  : _currentReadingController.text,
            ),
            rentalIncomeCode: 1500,
            incomeCode: 1256,
            cadastralKey: _cadastralKeyConnectionController.text,
            sector: int.parse(
              _sectorConnectionController.text.isEmpty
                  ? '0'
                  : _sectorConnectionController.text,
            ),
            account: int.parse(
              _accountConnectionController.text.isEmpty
                  ? '0'
                  : _accountConnectionController.text,
            ),
            readingValue: double.parse(
              _readingValueController.text.isNotEmpty
                  ? _readingValueController.text
                  : '0',
            ),
            connectionId: _connectionIdController.text,
            sewerRate: 0.0,
            averageConsumption:
                double.tryParse(_averageConsumptionController.text) ?? 0.0,
          ),
        );
      },
      fields: [
        {'label': 'ID de Conexión', 'value': _connectionIdController.text},
        {'label': 'Propietario', 'value': _connectionOwnerController.text},
        {'label': 'Dirección', 'value': _addressConnectionController.text},
        {
          'label': 'Descripción',
          'value': _descriptionController.text.isEmpty
              ? 'Sin descripción'
              : _descriptionController.text,
        },
        {
          'label': 'Número de Imágenes Adjuntas',
          'value': _attachedImages.length.toString(),
        },
        {
          'label': 'Modo de Envío',
          'value': widget.mode == 'manual' ? 'Manual' : 'Escaneo',
        },
        {
          'label': 'Lectura Anterior',
          'value': _currentReadingController.text.isEmpty
              ? 'Sin lectura anterior'
              : _currentReadingController.text,
        },
        {
          'label': 'Lectura Actual',
          'value': _newCurrentReadingController.text.isEmpty
              ? 'Sin lectura actual'
              : double.parse(
                  _newCurrentReadingController.text,
                ).toStringAsFixed(2),
        },
        {
          'label': 'Consumo (m³)',
          'value': '${_currentConsumptionController.text} m³',
        },
        {
          'label': 'Estado Consumo',
          'value': _currentConsumptionController.text.isEmpty
              ? 'Sin consumo'
              : double.parse(
                  _newCurrentReadingController.text,
                ).toStringAsFixed(2),
        },
      ],
    );
  }

  @override
  void dispose() {
    _newCurrentReadingController.removeListener(_updateCurrentConsumption);
    _previousReadingController.removeListener(_updateCurrentConsumption);
    _accountConnectionController.dispose();
    _addressConnectionController.dispose();
    _cardIdController.dispose();
    _cadastralKeyConnectionController.dispose();
    _connectionIdController.dispose();
    _connectionOwnerController.dispose();
    _currentReadingController.dispose();
    _previousReadingController.dispose();
    _readingIdController.dispose();
    _sectorConnectionController.dispose();
    _descriptionController.dispose();
    _averageConsumptionController.dispose();
    _currentConsumptionController.dispose();
    _previousConsumptionController.dispose();
    _readingValueController.dispose();
    _previousReadingDate.dispose();
    _newCurrentReadingController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label; // Propiedad final
  final Color color;
  final bool loading;
  final double height;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label, // Hacer 'label' required
    required this.color,
    this.loading = false,
    required this.height,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => !loading ? animationController.forward() : null,
      onTapUp: (_) => animationController.reverse(),
      onTapCancel: () => animationController.reverse(),
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.buttonBorderRadius(context),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: ResponsiveUtils.isSmallDevice(context) ? 8 : 12,
                    offset: Offset(
                      0,
                      ResponsiveUtils.isSmallDevice(context) ? 3 : 5,
                    ),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.buttonBorderRadius(context),
                    ),
                  ),
                  elevation: 0,
                  padding: ResponsiveUtils.cardPadding(context).copyWith(
                    left: ResponsiveUtils.scaleWidth(context, 0.04),
                    right: ResponsiveUtils.scaleWidth(context, 0.04),
                  ),
                  minimumSize: Size(double.infinity, height),
                ),
                child: loading
                    ? SizedBox(
                        width: ResponsiveUtils.iconMedium(context),
                        height: ResponsiveUtils.iconMedium(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: ResponsiveUtils.iconSmall(context),
                            color: Colors.white,
                          ),
                          ResponsiveUtils.hSpace(context, 0.03),
                          Text(
                            label,
                            style: ResponsiveUtils.buttonText(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
