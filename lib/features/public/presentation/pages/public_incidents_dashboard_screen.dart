import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/components/loaders/professional_loader.dart';
import 'package:app_properties/core/di/injection.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:app_properties/features/public/presentation/cubit/public_incident_kpis_cubit.dart';
import 'package:app_properties/features/public/presentation/cubit/public_incident_kpis_state.dart';
import 'package:app_properties/features/incidents/domain/entities/incident_kpi.model.dart';
import 'package:intl/intl.dart';

class PublicIncidentsDashboardScreen extends StatelessWidget {
  const PublicIncidentsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PublicIncidentKpisCubit>()..loadKpis(),
      child: const _PublicIncidentsDashboardView(),
    );
  }
}

class _PublicIncidentsDashboardView extends StatelessWidget {
  const _PublicIncidentsDashboardView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          'Dashboard de Incidentes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark ? colors.onSurface : Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? colors.onSurface : Colors.white,
          ),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
        backgroundColor: isDark ? colors.surfaceContainer : colors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<PublicIncidentKpisCubit, PublicIncidentKpisState>(
        builder: (context, state) {
          if (state is PublicIncidentKpisLoading ||
              state is PublicIncidentKpisInitial) {
            return const ProfessionalLoader(
              label: 'Cargando...',
              description: 'Se está cargando la información',
            );
          } else if (state is PublicIncidentKpisError) {
            return _buildErrorState(context, state.message, colors);
          } else if (state is PublicIncidentKpisLoaded) {
            return _buildDashboardContent(context, state.data, colors, isDark);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Ocurrió un error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<PublicIncidentKpisCubit>().loadKpis(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
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

  Widget _buildDashboardContent(
    BuildContext context,
    IncidentDashboardKpiResponse data,
    ColorScheme colors,
    bool isDark,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<PublicIncidentKpisCubit>().loadKpis(),
      color: colors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          _buildSummaryCards(data.kpisGenerales, colors, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Distribución por Estado', colors),
          const SizedBox(height: 12),
          _buildDistributionCards(data.porEstado, colors, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Distribución por Prioridad', colors),
          const SizedBox(height: 12),
          _buildPriorityCards(data.porPrioridad, colors, isDark),
          const SizedBox(height: 24),
          _buildSectionTitle('Distribución por Categoría', colors),
          const SizedBox(height: 12),
          _buildCategoryCards(data.porCategoria, colors, isDark),
          if (data.atencionInmediata.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle('Atención Inmediata (Críticos)', colors),
            const SizedBox(height: 12),
            _buildCriticalIncidents(data.atencionInmediata, colors, isDark),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSummaryCards(
    KpisGenerales kpis,
    ColorScheme colors,
    bool isDark,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        _buildKpiCard(
          'Total Reportados',
          kpis.totalIncidentes.toString(),
          'Todos los incidentes registrados en el sistema.',
          Icons.analytics_rounded,
          colors.primary,
          colors,
          isDark,
        ),
        _buildKpiCard(
          'Resueltos',
          kpis.totalResueltos.toString(),
          'Incidentes atendidos y solucionados.',
          Icons.check_circle_rounded,
          Colors.green.shade500,
          colors,
          isDark,
        ),
        _buildKpiCard(
          'Pendientes',
          kpis.totalPendientes.toString(),
          'A la espera de ser inspeccionados.',
          Icons.pending_actions_rounded,
          Colors.orange.shade500,
          colors,
          isDark,
        ),
        _buildKpiCard(
          'Críticos',
          kpis.totalCriticosActivos.toString(),
          'Requieren atención inmediata del equipo.',
          Icons.warning_rounded,
          Colors.red.shade500,
          colors,
          isDark,
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color iconColor,
    ColorScheme colors,
    bool isDark,
  ) {
    final bgColor = isDark ? colors.surfaceContainerHighest : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
        border: Border.all(
          color: isDark
              ? colors.outline.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withValues(alpha: 0.6),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCards(
    List<DistribucionEstado> estados,
    ColorScheme colors,
    bool isDark,
  ) {
    if (estados.isEmpty) {
      return const Text('No hay datos disponibles.');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: estados.map((estado) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainer
                : colors.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: 0.1)
                  : colors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                estado.estado,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? colors.onSurface
                      : colors.primary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado.cantidad.toString(),
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityCards(
    List<DistribucionPrioridad> prioridades,
    ColorScheme colors,
    bool isDark,
  ) {
    if (prioridades.isEmpty) {
      return const Text('No hay datos disponibles.');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: prioridades.map((prioridad) {
        Color priorityColor = colors.primary;
        final pLower = prioridad.prioridad.toLowerCase();
        if (pLower.contains('alta') || pLower.contains('crític')) {
          priorityColor = Colors.red.shade600;
        } else if (pLower.contains('media')) {
          priorityColor = Colors.orange.shade600;
        } else if (pLower.contains('baja')) {
          priorityColor = Colors.green.shade600;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainer
                : priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? colors.outline.withValues(alpha: 0.1)
                  : priorityColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_rounded, color: priorityColor, size: 16),
              const SizedBox(width: 8),
              Text(
                prioridad.prioridad,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? colors.onSurface : priorityColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prioridad.cantidad.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCards(
    List<DistribucionCategoria> categorias,
    ColorScheme colors,
    bool isDark,
  ) {
    if (categorias.isEmpty) {
      return const Text('No hay datos disponibles.');
    }
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return Column(
      children: categorias.map((categoria) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHighest : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.categoria,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Costo est.: ${formatter.format(categoria.costoTotal)}',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    categoria.cantidad.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    'casos',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCriticalIncidents(
    List<IncidenteCritico> criticos,
    ColorScheme colors,
    bool isDark,
  ) {
    return Column(
      children: criticos.map((critico) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.red.shade900.withValues(alpha: 0.2)
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade300.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade600,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      critico.incidentCode,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.red.shade200
                            : Colors.red.shade800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${critico.category} • ${critico.type}',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acometida: ${critico.connectionId}',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      critico.daysOpen.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'días',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
