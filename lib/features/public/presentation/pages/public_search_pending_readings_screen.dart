import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/components/loaders/professional_loader.dart';
import 'package:app_properties/core/di/injection.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';
import 'package:app_properties/core/services/pdf/pdf_export_service.dart';
import 'package:app_properties/features/searchs/domain/services/pdf_templates/pending_reading_pdf_template.dart';
import 'package:app_properties/features/searchs/domain/services/pdf_templates/all_pending_readings_pdf_template.dart';
import 'package:app_properties/features/searchs/presentation/cubit/pending_readings_cubit.dart';
import 'package:app_properties/features/searchs/presentation/cubit/pending_readings_state.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';

class PublicSearchPendingReadingsScreen extends StatelessWidget {
  const PublicSearchPendingReadingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PendingReadingsCubit>(),
      child: const _PublicSearchPendingReadingsView(),
    );
  }
}

class _PublicSearchPendingReadingsView extends StatefulWidget {
  const _PublicSearchPendingReadingsView();

  @override
  State<_PublicSearchPendingReadingsView> createState() =>
      _PublicSearchPendingReadingsViewState();
}

class _PublicSearchPendingReadingsViewState
    extends State<_PublicSearchPendingReadingsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<PendingReadingsCubit>().searchPendingReadings(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Background Gradient / Shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.secondary.withOpacity(isDark ? 0.15 : 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, colors),
                _buildSearchInput(colors),
                Expanded(child: _buildResultsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8, 24.0, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consulta tus comprobantes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Comprobantes y Planillas Pendientes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Clave Catastral o Cédula',
                    hintStyle: TextStyle(
                      color: colors.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: colors.primary),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send_rounded, color: colors.primary),
                onPressed: _onSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return BlocBuilder<PendingReadingsCubit, PendingReadingsState>(
      builder: (context, state) {
        if (state is PendingReadingsInitial) {
          return _buildEmptyState(
            context,
            Icons.search_rounded,
            'Ingresa un criterio de búsqueda',
            'Puedes buscar usando la clave catastral o tu número de cédula.',
          );
        } else if (state is PendingReadingsLoading) {
          return const ProfessionalLoader(
            label: 'Cargando...',
            description: 'Se está cargando la información',
          );
        } else if (state is PendingReadingsError) {
          return _buildEmptyState(
            context,
            Icons.error_outline_rounded,
            'Ocurrió un error',
            state.message,
            isError: true,
          );
        } else if (state is PendingReadingsLoaded) {
          if (state.readings.isEmpty) {
            return _buildEmptyState(
              context,
              Icons.check_circle_outline_rounded,
              '¡Al día!',
              'No se encontraron deudas pendientes para esta búsqueda.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            itemCount: state.readings.length + 1, // +1 for the user header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildUserHeaderBanner(context, state.readings);
              }
              final reading = state.readings[index - 1];
              return _buildDetailedDebtCard(context, reading);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    bool isError = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (isError ? colors.errorContainer : colors.primaryContainer)
                  .withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: isError ? colors.error : colors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeaderBanner(
    BuildContext context,
    List<PendingReadingResponse> readings,
  ) {
    final userRef = readings.first;
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    final banner = Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceContainerHighest.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            // <-- Este Row principal debe tener spaceBetween
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PRIMER BLOQUE (Alineado al Inicio / Izquierda) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Contribuyente:',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userRef.name} ${userRef.lastName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),

              // --- SEGUNDO BLOQUE (Alineado al Final / Derecha) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment
                    .end, // <-- Cambiado a 'end' para alinear el texto a la derecha
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // <-- center o start queda mejor visualmente aquí
                    children: [
                      Icon(
                        Icons.badge,
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Identificación:',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userRef.cardId,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        banner,
        const SizedBox(height: 8),
        if (readings.length > 1)
          ElevatedButton.icon(
            onPressed: () => _exportAllToPdf(context, readings),
            icon: const Icon(Icons.picture_as_pdf),
            label: Text('Descargar Todas (${readings.length}) en PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? colors.primaryContainer
                  : Colors.blue.shade900,
              foregroundColor: isDark
                  ? colors.onPrimaryContainer
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _exportAllToPdf(
    BuildContext context,
    List<PendingReadingResponse> readings,
  ) async {
    try {
      await sl<PdfExportService>().exportDocument(
        template: AllPendingReadingsPdfTemplate(),
        data: readings,
        filename: 'Planillas_Completas_${readings.first.cadastralKey}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: \$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildDetailedDebtCard(
    BuildContext context,
    PendingReadingResponse reading,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainer : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.cable, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Clave: ${reading.cadastralKey}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  color: colors.onSurfaceVariant,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Direc: ${reading.address}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.tertiaryContainer
                        : Colors.lightBlue.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reading.rate.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? colors.onTertiaryContainer : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Planilla General Section
          _buildSectionTitle(context, Icons.receipt_long, 'Planilla General'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildPlanillaGeneralTable(context, reading),
          ),
          _buildTotalRow(context, 'TOTAL A PAGAR:', reading.totalEpaaValue),

          // Tasa Basura Section
          _buildSectionTitle(
            context,
            Icons.delete_outline,
            'Detalle Tasa Basura',
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTasaBasuraTable(context, reading),
          ),
          _buildTotalRow(context, 'TOTAL TASA BASURA:', reading.totalTrashRate),

          // Mejoras Section
          _buildSectionTitle(
            context,
            Icons.business,
            'Mejoras Municipio Antonio Ante',
            isLight: true,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildMejorasTable(context, reading),
          ),
          _buildTotalRow(context, 'TOTAL MEJORAS:', reading.thirdPartyValue),

          // Gran Total
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerHigh
                  : Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final exportService = sl<PdfExportService>();
                          await exportService.exportDocument(
                            data: reading,
                            filename: 'PLANILLA_${reading.incomeCode}.pdf',
                            template: PendingReadingPdfTemplate(),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al generar PDF: $e'),
                                backgroundColor: colors.error,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Text(
                      'GRAN TOTAL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onTertiaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '\$${reading.adjustedTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onTertiaryContainer,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLight = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, double amount) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 80,
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanillaGeneralTable(
    BuildContext context,
    PendingReadingResponse reading,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return DataTable(
      headingRowHeight: 30,
      headingRowColor: WidgetStateProperty.all(
        isDark
            ? colors.surfaceContainerHighest
            : Colors.yellow.shade50.withOpacity(0.5),
      ),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 48,
      columnSpacing: 24,
      columns: const [
        DataColumn(
          label: Text(
            'Periodo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Consumo (m³)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Valor EPAA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Interés',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Recargo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'Total',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${reading.month.toUpperCase()} - ${reading.year}',
                    style: TextStyle(
                      color: isDark ? colors.primary : Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '⏱ ${reading.previousReading} → ${reading.currentReading} m³',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                '${reading.consumption} m³',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
            ),
            DataCell(
              Text(
                '\$${reading.epaaValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
            ),
            DataCell(
              Text(
                '\$${reading.interestValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
            ),
            DataCell(
              Text(
                reading.surcharge > 0
                    ? '\$${reading.surcharge.toStringAsFixed(2)}'
                    : '-',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
            ),
            DataCell(
              Text(
                '\$${reading.totalEpaaValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTasaBasuraTable(
    BuildContext context,
    PendingReadingResponse reading,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return DataTable(
      headingRowHeight: 30,
      headingRowColor: WidgetStateProperty.all(
        isDark
            ? colors.surfaceContainerHighest
            : Colors.yellow.shade50.withOpacity(0.5),
      ),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 48,
      columnSpacing: 24,
      columns: const [
        DataColumn(
          label: Text('Periodo', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'TB Actual',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'TB Anterior',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Saldo a Favor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Saldo (Próx. Mes)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Total a Pagar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(
              Text(
                '${reading.month.toUpperCase()} - ${reading.year}',
                style: TextStyle(
                  color: isDark ? colors.primary : Colors.blue.shade700,
                ),
              ),
            ),
            DataCell(Text('\$${reading.trashRate.toStringAsFixed(2)}')),
            DataCell(Text('\$${reading.trashRatePrevious.toStringAsFixed(2)}')),
            DataCell(
              Text(
                reading.balanceInFavorCurrentMonth > 0
                    ? '\$${reading.balanceInFavorCurrentMonth.toStringAsFixed(2)}'
                    : '-',
              ),
            ),
            DataCell(
              Text(
                reading.balanceInFavorNextMonth > 0
                    ? '\$${reading.balanceInFavorNextMonth.toStringAsFixed(2)}'
                    : '-',
              ),
            ),
            DataCell(
              Text(
                '\$${reading.totalTrashRate.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMejorasTable(
    BuildContext context,
    PendingReadingResponse reading,
  ) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return DataTable(
      headingRowHeight: 30,
      headingRowColor: WidgetStateProperty.all(
        isDark
            ? colors.surfaceContainerHighest
            : Colors.blue.shade50.withOpacity(0.5),
      ),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 48,
      columnSpacing: 48,
      columns: const [
        DataColumn(
          label: Text('Periodo', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text(
            'Valor Mejoras',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Total a Pagar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(
              Text(
                '${reading.month.toUpperCase()} - ${reading.year}',
                style: TextStyle(
                  color: isDark ? colors.primary : Colors.blue.shade700,
                ),
              ),
            ),
            DataCell(Text('\$${reading.thirdPartyValue.toStringAsFixed(2)}')),
            DataCell(
              Text(
                '\$${reading.thirdPartyValue.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
