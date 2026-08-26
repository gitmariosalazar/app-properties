import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/features/reading/presentation/scan/bloc/index.dart';
import 'package:app_properties/features/reading/presentation/scan/widgets/scanner_view.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Flag to prevent multiple navigations or processing
  bool _isProcessing = false;
  final GlobalKey<ScannerViewState> _scannerKey = GlobalKey<ScannerViewState>();

  void _handleCodeDetected(String code) {
    if (_isProcessing) return;

    final blocState = context.read<ReadingScanBloc>().state;
    if (blocState is ReadingScanLoading) return;

    _processCode(code);
  }

  void _processCode(String code) {
    setState(() => _isProcessing = true);

    try {
      final data = jsonDecode(code) as Map<String, dynamic>;
      final acometidaId = data['acometidaId']?.toString();

      if (acometidaId != null && acometidaId.isNotEmpty) {
        // Show scanning/processing message similar to user Code
        _showMessage('Escaneado: $acometidaId', Colors.green);
        context.read<ReadingScanBloc>().add(LoadReadingScanInfo(acometidaId));
      } else {
        _showError('QR no contiene acometidaId.');
        _resetProcessing();
      }
    } catch (e) {
      _showError('QR inválido: $e');
      _resetProcessing();
    }
  }

  void _resetProcessing() {
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: ResponsiveUtils.bodyMedium(context)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: ResponsiveUtils.bodyMedium(context)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetScanner() {
    // Calls the robust reset in ScannerView
    _scannerKey.currentState?.reset();
    if (_isProcessing) {
      setState(() => _isProcessing = false);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Escáner reiniciado.',
          style: ResponsiveUtils.bodySmall(context),
        ),
        backgroundColor: Colors.blueAccent,
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
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: ResponsiveUtils.cardElevation(context),
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
        child: BlocConsumer<ReadingScanBloc, ReadingScanState>(
          listener: (context, state) {
            if (state is ReadingScanLoaded) {
              final bloc = context.read<ReadingScanBloc>();
              context
                  .push(
                    '/form',
                    extra: {'reading': state.reading, 'mode': 'scan'},
                  )
                  .then((_) {
                    // Reset on return
                    if (mounted) {
                      setState(() => _isProcessing = false);
                      bloc.add(ResetReadingScan());
                      _scannerKey.currentState
                          ?.reset(); // Flash to indicate ready
                    }
                  });
            } else if (state is ReadingScanError) {
              _showError(state.message);
              _resetProcessing();
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                ScannerView(
                  key: _scannerKey,
                  onDetect: _handleCodeDetected,
                  onPermissionDenied: () =>
                      _showError('Se necesitan permisos de cámara'),
                ),
                if (state is ReadingScanLoading) _buildLoadingOverlay(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
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
}
