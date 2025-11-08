// lib/features/scan/presentation/pages/scan_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart'; // ← AÑADIDO
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/button/widget_button.dart';
import 'package:app_properties/main.dart';
import 'package:app_properties/features/properties/list/presentation/scan/blocs/index.dart';

class PropertyScanPage extends StatefulWidget {
  const PropertyScanPage({super.key});

  @override
  State<PropertyScanPage> createState() => _PropertyScanPageState();
}

class _PropertyScanPageState extends State<PropertyScanPage>
    with WidgetsBindingObserver, RouteAware {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
    autoStart: false,
    returnImage: false,
  );

  Rect? _scanWindow;
  bool _isTorchOn = false;
  bool _isRestarting = false;
  bool _isBorderHighlighted = true;
  bool _shouldPauseCamera = false;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    _updateScanWindow();
    _startScanner();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _updateScanWindow() {
    final size = MediaQuery.of(context).size;
    final isSmall = ResponsiveUtils.isSmallDevice(context);
    final scanAreaSize = size.width * (isSmall ? 0.55 : 0.65);
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    _scanWindow = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);
  }

  @override
  void didPopNext() {
    debugPrint('didPopNext: Reanudando escáner');
    if (mounted && !_shouldPauseCamera) {
      _resumeScanning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      _resumeScanning();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  // ────────────────────────────────────────────────
  // ESCÁNER
  // ────────────────────────────────────────────────

  Future<void> _startScanner() async {
    if (_isStarting) return;
    _isStarting = true;

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showError('Se requiere permiso de cámara.');
      _isStarting = false;
      return;
    }

    try {
      await _controller.start();
      if (mounted) setState(() {});
    } catch (e) {
      _showError('Error al iniciar el escáner: $e');
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _resumeScanning() async {
    if (_isRestarting || _shouldPauseCamera) return;
    _isRestarting = true;

    try {
      await _controller.start();
      if (mounted) {
        setState(() => _isBorderHighlighted = true);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) setState(() => _isBorderHighlighted = false);
        });
      }
    } catch (e) {
      _showError('Error reiniciando escáner: $e');
    } finally {
      _isRestarting = false;
    }
  }

  Future<void> _resetScanner() async {
    if (context.read<ConnectionWithPropertiesBloc>().state
        is ConnectionWithPropertiesLoading)
      return;

    setState(() {
      _shouldPauseCamera = false;
    });
    await _controller.stop();
    await _resumeScanning();
    _showMessage('Escáner reiniciado.', Colors.blueAccent);
  }

  // ────────────────────────────────────────────────
  // ESCANEO DESDE FOTO
  // ────────────────────────────────────────────────

  Future<void> _scanFromPhoto() async {
    final picker = ImagePicker(); // ← CORREGIDO
    final image = await picker.pickImage(
      source: ImageSource.gallery,
    ); // ← CORREGIDO
    if (image == null) {
      _showMessage('No se seleccionó imagen.', Colors.orange);
      return;
    }

    // Mostrar loading manualmente
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Analizando imagen...')));

    try {
      final result = await _controller.analyzeImage(image.path);
      if (result?.barcodes.isNotEmpty == true) {
        final code = result!.barcodes.first.rawValue;
        if (code != null) {
          await _controller.stop();
          _handleQRCode(code);
        } else {
          _showError('Código QR no válido.');
        }
      } else {
        _showError('No se encontró QR en la imagen.');
      }
    } catch (e) {
      _showError('Error al analizar imagen: $e');
    }
  }

  // ────────────────────────────────────────────────
  // MANEJO DE QR
  // ────────────────────────────────────────────────

  void _handleQRCode(String code) {
    try {
      final data = jsonDecode(code) as Map<String, dynamic>;
      final acometidaId = data['acometidaId']?.toString();

      if (acometidaId == null || acometidaId.isEmpty) {
        _showError('QR no contiene acometidaId.');
        _resumeScanning();
        return;
      }

      _showMessage('Escaneado: $acometidaId', Colors.green);
      context.read<ConnectionWithPropertiesBloc>().add(
        FetchConnectionWithPropertiesEvent(acometidaId),
      );
    } catch (e) {
      _showError('QR inválido: $e');
      _resumeScanning();
    }
  }

  // ────────────────────────────────────────────────
  // UI HELPERS
  // ────────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: ResponsiveUtils.bodyMedium(context)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: ResponsiveUtils.bodyMedium(context)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ← AÑADIDO

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Escanear Código QR',
          style: ResponsiveUtils.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: ResponsiveUtils.cardElevation(context),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reiniciar',
            icon: Icon(
              Icons.refresh,
              size: ResponsiveUtils.iconMedium(context),
              color: Colors.white,
            ),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ESCÁNER
            MobileScanner(
              controller: _controller,
              scanWindow: _scanWindow,
              onDetect: (capture) {
                if (_shouldPauseCamera ||
                    context.read<ConnectionWithPropertiesBloc>().state
                        is ConnectionWithPropertiesLoading) {
                  return;
                }
                final code = capture.barcodes.firstOrNull?.rawValue;
                if (code != null && code.isNotEmpty) {
                  _controller.stop();
                  _handleQRCode(code);
                }
              },
            ),

            // OVERLAY
            _buildScannerOverlay(context),

            // BOTONES INFERIORES
            _buildBottomControls(context, theme), // ← theme pasado
            // INSTRUCCIONES
            _buildInstructions(context),

            // ESTADO DE CARGA (BLoC)
            BlocConsumer<
              ConnectionWithPropertiesBloc,
              ConnectionWithPropertiesState
            >(
              listener: (context, state) {
                debugPrint('ConnectionWithPropertiesBloc State: $state');
                debugPrint(
                  'Data: ${state is ConnectionWithPropertiesLoaded ? state : 'N/A'}',
                );
                debugPrint(
                  'Error: ${state is ConnectionWithPropertiesError ? state.message : 'N/A'}',
                );

                if (state is ConnectionWithPropertiesLoaded) {
                  debugPrint(
                    '--- --- --- ${state.connection} propiedades encontradas',
                  );
                  _shouldPauseCamera = true;
                  context.push(
                    '/update-form',
                    extra: {'connection': state.connection, 'mode': 'scan'},
                  );
                } else if (state is ConnectionWithPropertiesError) {
                  _showError(state.message);
                  _resumeScanning();
                }
              },
              builder: (context, state) {
                if (state is ConnectionWithPropertiesLoading) {
                  return _buildLoadingOverlay();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: Container(
        padding: ResponsiveUtils.cardPadding(context),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.cardBorderRadius(context),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Cargando lectura...',
              style: ResponsiveUtils.bodyLarge(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, ThemeData theme) {
    return Positioned(
      left: ResponsiveUtils.mediumSpacing(context),
      right: ResponsiveUtils.mediumSpacing(context),
      bottom: ResponsiveUtils.mediumSpacing(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.smallSpacing(context),
            ),
            padding: ResponsiveUtils.cardPadding(context),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.cardBorderRadius(context),
              ),
            ),
            child: Text(
              'Estado: ${_controller.value.isInitialized ? "Activo" : "Inactivo"}',
              style: ResponsiveUtils.bodySmall(
                context,
              ).copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: _isTorchOn ? Icons.flash_off : Icons.flash_on,
                circular: true, // ← CORREGIDO
                onPressed: () async {
                  try {
                    await _controller.toggleTorch();
                    setState(() => _isTorchOn = !_isTorchOn);
                  } catch (e) {
                    _showError('Error linterna: $e');
                  }
                },
              ),
              ActionButton(
                icon: Icons.photo_library,
                label: 'Desde Foto',
                onPressed: _scanFromPhoto,
              ),
              ActionButton(
                icon: Icons.restart_alt_rounded,
                circular: true, // ← CORREGIDO
                onPressed: _resetScanner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Positioned(
      top: ResponsiveUtils.mediumSpacing(context),
      left: ResponsiveUtils.mediumSpacing(context),
      right: ResponsiveUtils.mediumSpacing(context),
      child: Container(
        padding: ResponsiveUtils.cardPadding(context),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.cardBorderRadius(context),
          ),
        ),
        child: Text(
          'Alinea el código QR dentro del marco',
          style: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isSmall = ResponsiveUtils.isSmallDevice(context);
        final scanAreaSize = width * (isSmall ? 0.55 : 0.65);
        final left = (width - scanAreaSize) / 2;
        final top = (height - scanAreaSize) / 2;

        _scanWindow = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.cardBorderRadius(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.cardBorderRadius(context),
                  ),
                  border: Border.all(
                    color: _isBorderHighlighted
                        ? Colors.yellow
                        : Theme.of(context).colorScheme.primary,
                    width: _isBorderHighlighted ? 4 : 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCornerMarker(context, 3.1416),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCornerMarker(context, -1.5708),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCornerMarker(context, 1.5708),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCornerMarker(context, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerMarker(
    BuildContext context,
    double rotationAngleInRadians,
  ) {
    return Transform.rotate(
      angle: rotationAngleInRadians,
      child: Container(
        width: ResponsiveUtils.iconMedium(context),
        height: ResponsiveUtils.iconMedium(context),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: _isBorderHighlighted
                  ? Colors.yellow
                  : Theme.of(context).colorScheme.primary,
              width: _isBorderHighlighted ? 4 : 2,
            ),
            left: BorderSide(
              color: _isBorderHighlighted
                  ? Colors.yellow
                  : Theme.of(context).colorScheme.primary,
              width: _isBorderHighlighted ? 4 : 2,
            ),
          ),
        ),
      ),
    );
  }
}
