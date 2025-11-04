import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_properties/main.dart';
import 'package:app_properties/components/button/widget_button.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
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
  bool _isProcessing = false;
  String? _lastScannedCode;
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
    final size = MediaQuery.of(context).size;
    final isSmall = ResponsiveUtils.isSmallDevice(context);
    final scanAreaSize = size.width * (isSmall ? 0.55 : 0.65);
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    _scanWindow = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);
    _startScanner();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    debugPrint('didPopNext called: Reanudando escáner');
    if (mounted) {
      _shouldPauseCamera = false;
      _resumeScanning();
    }
  }

  Future<void> _startScanner() async {
    if (_isStarting) return;
    _isStarting = true;
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _showError('Se requiere permiso de cámara para escanear.');
      }
      _isStarting = false;
      return;
    }
    try {
      if (!_controller.value.isInitialized) {
        await _controller.start();
        if (mounted) setState(() {});
      } else {
        await _controller.stop();
        await _controller.start();
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al iniciar el escáner: $e');
      }
    } finally {
      _isStarting = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      _resumeScanning();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  Future<void> _handleScan(String code) async {
    setState(() {
      _isProcessing = true;
      _lastScannedCode = null;
    });

    try {
      final data = jsonDecode(code);
      if (data is! Map<String, dynamic> || !data.containsKey('acometidaId')) {
        _showError('Código QR no contiene un acometidaId válido.');
        if (mounted) await _resumeScanning();
        return;
      }

      final acometidaId = data['acometidaId'];
      _showMessage(
        'Código QR escaneado correctamente: $acometidaId',
        Colors.green,
      );

      final String baseUrl = Environment.apiUrl;
      final response = await http.get(
        Uri.parse(
          '$baseUrl/connections/find-connection-by-property-cadastral-key/$acometidaId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['data'] is Map<String, dynamic>) {
          final apiData = responseData['data'] as Map<String, dynamic>;

          _showMessage('Acometida: ${apiData['connectionId']}', Colors.green);

          await _controller.stop();
          _shouldPauseCamera = true;

          if (mounted) {
            await context.push('/update-form', extra: {'data': apiData});
          }
        } else {
          _showError('Datos incompletos en la respuesta.');
          if (mounted) await _resumeScanning();
        }
      } else {
        _showError('Error ${response.statusCode}: ${response.body}');
        if (mounted) await _resumeScanning();
      }
    } catch (e) {
      _showError('Error procesando el código QR: $e');
      if (mounted) await _resumeScanning();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastScannedCode = null;
        });
      }
    }
  }

  Future<void> _resumeScanning() async {
    if (_isRestarting || _shouldPauseCamera) return;
    _isRestarting = true;

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Se requiere permiso de cámara para escanear.');
        _isRestarting = false;
        return;
      }
      await _controller.start();

      if (mounted) {
        setState(() {
          _isBorderHighlighted = true;
        });
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) setState(() => _isBorderHighlighted = false);
        });
      }
    } catch (e) {
      _showError('Error reiniciando el escáner: $e');
    } finally {
      _isRestarting = false;
    }
  }

  Future<void> _resetScanner() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = false;
      _shouldPauseCamera = false;
      _lastScannedCode = null;
    });
    await _controller.stop();
    await _resumeScanning();
    _showMessage('Escáner reiniciado.', Colors.blueAccent);
  }

  Future<void> _scanFromPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      _showMessage('No se seleccionó ninguna imagen.', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = null;
    });
    try {
      final result = await _controller.analyzeImage(image.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final String? code = result.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          await _controller.stop();
          await _handleScan(code);
        } else {
          _showError('No se detectó un código QR en la imagen.');
          setState(() => _isProcessing = false);
          await _resumeScanning();
        }
      } else {
        _showError('No se detectó un código QR en la imagen.');
        setState(() => _isProcessing = false);
        await _resumeScanning();
      }
    } catch (e) {
      _showError('Error al escanear la imagen: $e');
      setState(() => _isProcessing = false);
      await _resumeScanning();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            tooltip: 'Reiniciar escáner',
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
              size: ResponsiveUtils.iconMedium(context),
            ),
            onPressed: _resetScanner,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () async {
                await _resumeScanning();
              },
              child: MobileScanner(
                controller: _controller,
                scanWindow: _scanWindow,
                onDetect: (capture) async {
                  if (_isProcessing || _shouldPauseCamera) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final barcode = barcodes.first;
                    final String? code = barcode.rawValue;
                    if (code != null && code.isNotEmpty) {
                      setState(() {
                        _isProcessing = true;
                        try {
                          final data = jsonDecode(code);
                          _lastScannedCode = data['acometidaId']?.toString();
                        } catch (_) {
                          _lastScannedCode = null;
                        }
                      });
                      await _controller.stop();
                      await _handleScan(code);
                    }
                  }
                },
              ),
            ),
            _buildScannerOverlay(context),
            Positioned(
              left: ResponsiveUtils.mediumSpacing(context),
              right: ResponsiveUtils.mediumSpacing(context),
              bottom: ResponsiveUtils.mediumSpacing(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Estado: ${_controller.value.isInitialized ? "Iniciado" : "No iniciado"}',
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
                        circular: true,
                        onPressed: () async {
                          if (_controller.value.isInitialized) {
                            try {
                              await _controller.toggleTorch();
                              setState(() {
                                _isTorchOn = !_isTorchOn;
                              });
                            } catch (e) {
                              _showError('Error al alternar la linterna: $e');
                            }
                          }
                        },
                      ),
                      ActionButton(
                        icon: Icons.photo_library,
                        label: 'Escanear desde Foto',
                        onPressed: _scanFromPhoto,
                      ),
                      ActionButton(
                        icon: Icons.restart_alt_rounded,
                        circular: true,
                        onPressed: _resetScanner,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
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
                  'Alinea el código QR dentro del marco para escanear',
                  style: ResponsiveUtils.bodyLarge(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (_isProcessing)
              Center(
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
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      ResponsiveUtils.vSpace(context, 0.015),
                      Text(
                        'Procesando',
                        style: ResponsiveUtils.bodyLarge(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ResponsiveUtils.vSpace(context, 0.015),
                      Text(
                        _lastScannedCode != null ? ' $_lastScannedCode' : '',
                        style: ResponsiveUtils.bodyLarge(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
