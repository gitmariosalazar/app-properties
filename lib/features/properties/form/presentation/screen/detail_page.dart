import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_datasource.dart';
import 'package:app_properties/features/properties/search/data/mappers/connection_mapper.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/services/document_export_service.dart';
import 'package:app_properties/components/badge/custom_badge.dart';
import 'package:app_properties/utils/convert_coordinates.dart';
import 'package:app_properties/features/properties/form/documents/domain/usecases/upload_document_usecase.dart';
import 'package:app_properties/components/common/custom_overlay_snack_bar.dart';

class DetailPage extends StatefulWidget {
  final String cadastralKey;

  const DetailPage({super.key, required this.cadastralKey});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  String? _errorMessage;
  ConnectionEntity? _connection;

  @override
  void initState() {
    super.initState();
    _loadConnectionDetails();
  }

  Future<void> _loadConnectionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataSource = di.sl<RemoteConnectionDataSource>();
      final responses = await dataSource
          .getConnectionByCadastralKeyOrClientIdOrCardId(widget.cadastralKey);

      if (responses.isEmpty) {
        throw Exception(
          'No se encontraron registros actualizados para la clave catastral provista.',
        );
      }

      // Map response to domain entity
      final entity = responses.first.toEntity();

      if (mounted) {
        setState(() {
          _connection = entity;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generatePdfReport() async {
    if (_connection == null || _isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final exportService = di.sl<DocumentExportService>();

      // 1. Generar los bytes del PDF para subirlos al servidor (en memoria local, es muy veloz)
      final pdfBytes = await exportService.generateConnectionActaBytes(
        _connection!,
      );

      // 2. Mostrar inmediatamente el mensaje de generación exitosa del acta
      if (mounted) {
        CustomOverlaySnackBar.show(
          context: context,
          message: '¡Acta de Inspección generada con éxito!',
          type: SnackBarType.success,
        );
      }

      // 3. Iniciar la carga al servidor en segundo plano (asíncronamente) para que no bloquee
      //    la ejecución de la compartición nativa que se abre a continuación.
      final uploadUseCase = di.sl<UploadDocumentUseCase>();
      uploadUseCase(
        fileBytes: pdfBytes,
        filename: 'ACTA_Acometida_${_connection!.connectionId}.pdf',
        codigoTipoDocumento: 'ACTA_ENTREGA_RECEPCION',
        entityType: 'acometida',
        entityId: _connection!.connectionId,
        nivelAcceso: 'PUBLICO',
        rolesPermitidos: ['ADMIN'],
        metadatosExtras: {
          'observacion':
              'Acta generada automáticamente desde la aplicación móvil.',
        },
      ).then((uploadResult) {
        if (mounted) {
          uploadResult.fold(
            (failure) {
              CustomOverlaySnackBar.show(
                context: context,
                message:
                    'Acta guardada, pero no se pudo sincronizar en el servidor: ${failure.message}',
                type: SnackBarType.warning,
              );
            },
            (uploadedDoc) {
              CustomOverlaySnackBar.show(
                context: context,
                message: '¡Acta respaldada con éxito en el servidor!',
                type: SnackBarType.success,
              );
            },
          );
        }
      });

      // 4. Abrir la ventana de compartir nativa (bloquea la ejecución en Flutter hasta que se cierre)
      await exportService.exportConnectionActa(_connection!);
    } catch (e) {
      if (mounted) {
        CustomOverlaySnackBar.show(
          context: context,
          message: 'Error al generar el acta de inspección: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Detalle de Actualización',
          style: theme.textTheme.titleMedium?.copyWith(
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
          onPressed: () => context.go('/home'),
        ),
        backgroundColor: cs.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient decoration
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withValues(alpha: 0.05), cs.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          if (_isLoading)
            _buildLoadingState(theme, cs)
          else if (_errorMessage != null)
            _buildErrorState(theme, cs)
          else
            _buildContent(theme, cs),

          if (_isGeneratingPdf) _buildPdfGenerationOverlay(theme, cs),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: cs.primary, strokeWidth: 4),
          const SizedBox(height: 16),
          Text(
            'Consultando servidor...',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: cs.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un inconveniente',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConnectionDetails,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme cs) {
    final conn = _connection!;

    // Determine Owner Name
    String ownerName = 'Sin Nombre';
    String ownerDoc = 'N/A';
    bool isNatural = conn.person != null;

    if (isNatural) {
      ownerName =
          '${conn.person!.firstName ?? ''} ${conn.person!.lastName ?? ''}'
              .trim();
      ownerDoc = conn.clientId;
    } else if (conn.company != null) {
      ownerName =
          conn.company!.businessName ??
          conn.company!.commercialName ??
          'Empresa Registrada';
      ownerDoc = conn.company!.ruc;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(context.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SUCCESS STAMP BANNER
                _buildSuccessBanner(theme, cs),
                const SizedBox(height: 10),
                // CLIENT CARD
                _buildSectionCard(
                  theme: theme,
                  cs: cs,
                  title: 'Información del Propietario',
                  icon: Icons.person_rounded,
                  children: [
                    _buildDetailRow(
                      theme,
                      Icons.person_outline_rounded,
                      'Nombre:',
                      ownerName,
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.badge_outlined,
                      'Identificación:',
                      ownerDoc,
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.people_outline_rounded,
                      'Tipo de Cliente:',
                      isNatural ? 'Persona Natural' : 'Persona Jurídica',
                    ),
                    if (isNatural && conn.person!.address != null)
                      _buildDetailRow(
                        theme,
                        Icons.location_on_outlined,
                        'Dirección:',
                        conn.person!.address!,
                      ),
                    if (!isNatural && conn.company!.address != null)
                      _buildDetailRow(
                        theme,
                        Icons.location_on_outlined,
                        'Dirección:',
                        conn.company!.address!,
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // CONNECTION CARD
                _buildSectionCard(
                  theme: theme,
                  cs: cs,
                  title: 'Detalles de Acometida',
                  icon: Icons.water_drop_rounded,
                  children: [
                    _buildDetailRow(
                      theme,
                      Icons.vpn_key_outlined,
                      'Clave Catastral:',
                      conn.connectionCadastralKey,
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.speed_rounded,
                      'Nº de Medidor:',
                      conn.connectionMeterNumber ?? 'Sin Medidor',
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.speed_rounded,
                      'Nº de Medidor Ant:',
                      conn.connectionMeterNumberPreview ?? 'Sin Medidor',
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.account_balance_wallet_outlined,
                      'Nº de Cuenta:',
                      conn.connectionAccount.toString(),
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.grid_view_rounded,
                      'Sector:',
                      conn.connectionSector.toString(),
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.monetization_on_outlined,
                      'Tarifa:',
                      conn.connectionRateName,
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.water_rounded,
                      'Alcantarillado:',
                      conn.connectionSewerage == true ? 'Posee' : 'No Posee',
                    ),
                    _buildDetailRow(
                      theme,
                      Icons.info_outline_rounded,
                      'Estado:',
                      conn.connectionStateId == 1 ? 'Activa' : 'Inactiva',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // GEOLOCATION CARD
                _buildSectionCard(
                  theme: theme,
                  cs: cs,
                  title: 'Ubicación del Predio',
                  icon: Icons.map_rounded,
                  children: (() {
                    final coords = extractCoordinates(
                      conn.connectionCoordinates ?? '',
                    );
                    final lat = coords['latitude'];
                    final lng = coords['longitude'];
                    return [
                      _buildDetailRow(
                        theme,
                        Icons.location_searching_rounded,
                        'Latitud:',
                        lat != null ? lat.toStringAsFixed(8) : 'Sin registro',
                      ),
                      _buildDetailRow(
                        theme,
                        Icons.location_searching_rounded,
                        'Longitud:',
                        lng != null ? lng.toStringAsFixed(8) : 'Sin registro',
                      ),
                      _buildDetailRow(
                        theme,
                        Icons.filter_hdr_rounded,
                        'Altitud:',
                        conn.connectionAltitude != null
                            ? '${conn.connectionAltitude!.toStringAsFixed(1)} m'
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        theme,
                        Icons.gps_fixed_rounded,
                        'Precisión:',
                        conn.connectionPrecision != null
                            ? '${(conn.connectionPrecision! * 100).toStringAsFixed(0)}%'
                            : 'N/A',
                      ),
                      if (conn.connectionGeometricZone != null &&
                          conn.connectionGeometricZone!.isNotEmpty)
                        _buildDetailRow(
                          theme,
                          Icons.layers_outlined,
                          'Zona Geométrica:',
                          conn.connectionGeometricZone!,
                        ),
                    ];
                  })(),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),

        // BOTTOM ACTION BUTTONS BAR
        _buildBottomActionBar(theme, cs),
      ],
    );
  }

  Widget _buildSuccessBanner(ThemeData theme, ColorScheme cs) {
    final stateActive = _connection?.connectionStateId == 1;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Actualización Exitosa!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'La base de datos fue actualizada y verificada.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          CustomBadge(
            label: stateActive ? 'Activo' : 'Inactivo',
            theme: stateActive
                ? BadgeColorTheme.success
                : BadgeColorTheme.danger,
            size: BadgeSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required ColorScheme cs,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 175,
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generatePdfReport,
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Generar Acta',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.logout_rounded, color: cs.error),
            label: Text(
              'Salir',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.error,
                letterSpacing: 0.3,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error.withValues(alpha: 0.08),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfGenerationOverlay(ThemeData theme, ColorScheme cs) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Card(
          color: theme.cardColor,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: cs.primary, strokeWidth: 4),
                const SizedBox(height: 20),
                Text(
                  'Generando Acta de Inspección...',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Creando documento PDF oficial',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
