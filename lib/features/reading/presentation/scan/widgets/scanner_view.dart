import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/button/widget_button.dart';
import 'dart:math' as math;

class ScannerView extends StatefulWidget {
  final void Function(String code) onDetect;
  final VoidCallback? onPermissionDenied;

  const ScannerView({
    super.key,
    required this.onDetect,
    this.onPermissionDenied,
  });

  @override
  State<ScannerView> createState() => ScannerViewState();
}

class ScannerViewState extends State<ScannerView> with WidgetsBindingObserver {
  // MobileScannerController is robust.
  // We use autoStart: false initially and start manually to have full control if needed,
  // BUT to fix the "white screen" bug, usually autoStart: true is best.
  // However, user says "no escanea nada". This might mean Detection isn't firing.
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed
        .noDuplicates, // Reverting to noDuplicates as it's often safer for basic usage if logic is correct
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
    autoStart: true,
    returnImage: false,
  );

  bool _isTorchOn = false;
  bool _isPermissionGranted = false;
  bool _isCheckingPermission = true;
  bool _isBorderHighlighted = true; // Start highlighted to show it's active

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (mounted) setState(() => _isCheckingPermission = true);
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) setState(() => _isPermissionGranted = true);
      _flashBorder();
    } else {
      if (mounted) setState(() => _isPermissionGranted = false);
      widget.onPermissionDenied?.call();
    }
    if (mounted) setState(() => _isCheckingPermission = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      // Sometimes camera needs a nudge on resume
      _controller.start();
    }
  }

  // Simplified detection logic
  void _handleDetect(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      _flashBorder();
      widget.onDetect(code);
    }
  }

  void _flashBorder() {
    if (!mounted) return;
    setState(() => _isBorderHighlighted = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _isBorderHighlighted = false);
    });
  }

  void reset() {
    // Reset internal state if needed.
    // For noDuplicates, stopping and starting might be needed to clear buffer?
    // MobileScanner 7.x usually clears buffer on stop/start.
    _controller.stop().then((_) => _controller.start());
    _flashBorder();
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      setState(() => _isTorchOn = !_isTorchOn);
    } catch (e) {
      debugPrint('Torch error: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final result = await _controller.analyzeImage(image.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final code = result.barcodes.first.rawValue;
        if (code != null) {
          _handleDetect(result);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No se encontró QR')));
      }
    } catch (e) {
      debugPrint('Analyze error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isPermissionGranted) {
      return Center(
        child: Text("Sin Permiso de Cámara"),
      ); // Simplified fallback
    }

    // We REMOVE scanWindow from MobileScanner widget for now.
    // Sometimes crop is wrong calculations (pixel ratio etc).
    // Let's scan full screen but SHOW overlay. This guarantees detection works anywhere,
    // and user won't notice if they align it 'mostly' right.
    // Optimization is secondary to Functionality.

    final size = MediaQuery.of(context).size;
    final isSmall = ResponsiveUtils.isSmallDevice(context);
    final scanAreaSize = size.width * (isSmall ? 0.55 : 0.65);
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanWindowRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _handleDetect,
          fit: BoxFit.cover,
          // scanWindow: scanWindowRect, // REMOVED to fix "No Scanea nada" (if crop was wrong)
        ),
        _buildScannerOverlay(context, scanWindowRect),
        _buildBottomControls(context),
        _buildInstructions(context),
      ],
    );
  }

  Widget _buildScannerOverlay(BuildContext context, Rect scanWindow) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(color: Colors.black),
              Positioned(
                left: scanWindow.left,
                top: scanWindow.top,
                child: Container(
                  width: scanWindow.width,
                  height: scanWindow.height,
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
          left: scanWindow.left,
          top: scanWindow.top,
          child: Container(
            width: scanWindow.width,
            height: scanWindow.height,
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
  }

  Widget _buildCornerMarker(BuildContext context, double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
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

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      left: ResponsiveUtils.mediumSpacing(context),
      right: ResponsiveUtils.mediumSpacing(context),
      bottom: ResponsiveUtils.mediumSpacing(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, MobileScannerState state, child) {
              return Container(
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
                  'Estado: ${state.isInitialized ? "Activo" : "Inactivo"}',
                  style: ResponsiveUtils.bodySmall(
                    context,
                  ).copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: _isTorchOn ? Icons.flash_off : Icons.flash_on,
                circular: true,
                onPressed: _toggleTorch,
              ),
              ActionButton(
                icon: Icons.photo_library,
                label: 'Desde Foto',
                onPressed: _pickImage,
                circular: true,
                disabled: false,
              ),
              ActionButton(
                icon: Icons.restart_alt_rounded,
                circular: true,
                onPressed: () => reset(),
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
}
