import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:app_properties/features/properties/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:app_properties/utils/responsive_utils.dart';
import 'package:app_properties/components/badge/custom_badge.dart';

// Premium semantic status colors matching the modern design system
const _kGreen = Color(0xFF10B981); // Vibrant Emerald Green
const _kOrange = Color(0xFFF59E0B); // Modern Amber Gold
const _kRed = Color(0xFFEF4444); // Warm Crimson Red
const _kBlue = Color(0xFF3B82F6); // Sleek Cobalt Blue
const _kTeal = Color(0xFF14B8A6); // Clean Teal

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DashboardCubit>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().startWatching();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTablet = context.isTablet;

    // Obtener el nombre del usuario de la sesión
    final loginState = context.watch<LoginCubit>().state;
    final userName = loginState is LoginSuccess
        ? loginState.user.firstName
        : 'Administrador';

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.surface,
              cs.surfaceContainerLow.withValues(alpha: 0.8),
              cs.surfaceContainer.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              return RefreshIndicator(
                color: cs.primary,
                backgroundColor: cs.surfaceContainerHigh,
                onRefresh: () => context.read<DashboardCubit>().refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(context, cs, userName),
                    ),

                    if (state is DashboardLoading)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: cs.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    else if (state is DashboardError)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorView(message: state.message),
                      )
                    else if (state is DashboardLoaded) ...[
                      // Resumen & KPIs
                      SliverToBoxAdapter(
                        child: _buildResumenGrid(context, cs, state.stats),
                      ),

                      // Coberturas (Medidores y Alcantarillado) + Calidad GPS
                      SliverToBoxAdapter(
                        child: _buildCoberturasGrid(context, cs, state.stats),
                      ),

                      // Avance por Zonas
                      SliverToBoxAdapter(
                        child: _buildZonesSection(context, cs, state.stats),
                      ),

                      // Distribuciones (Categorías y Tarifas)
                      SliverToBoxAdapter(
                        child: _buildDistributionsSection(
                          context,
                          cs,
                          state.stats,
                        ),
                      ),

                      // Estado de Red e Histórico
                      SliverToBoxAdapter(
                        child: _buildNetworkAndHistorySection(
                          context,
                          cs,
                          state.stats,
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: isTablet ? 48 : 32),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header Widget ─────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ColorScheme cs, String userName) {
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días 🌅';
    if (hour >= 12 && hour < 18) greeting = 'Buenas tardes ☀️';
    if (hour >= 18) greeting = 'Buenas noches 🌙';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.mediumSpacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: context.bodySmall.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.extraSmallSpacing * 0.4),
                Text(
                  userName,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: context.extraSmallSpacing * 0.8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.smallSpacing * 0.8,
                    vertical: context.extraSmallSpacing * 0.6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.15),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _kGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: context.extraSmallSpacing * 1.5),
                      Text(
                        'EPAA-AA · Catastro Predial',
                        style: context.bodySmall.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _AvatarButton(),
        ],
      ),
    );
  }

  // ── Resumen & KPI Grid ───────────────────────────────────────────────────
  Widget _buildResumenGrid(
    BuildContext context,
    ColorScheme cs,
    DashboardStats stats,
  ) {
    final r = stats.resumen;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.smallSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('RESUMEN GENERAL'),
          SizedBox(height: context.smallSpacing * 1.5),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  icon: Icons.domain_rounded,
                  iconColor: cs.primary,
                  title: 'Predios Totales',
                  value: r.totalUniverso.toString(),
                  subtitle: 'Universo catastral',
                  progress: 1,
                ),
              ),
              SizedBox(width: context.mediumSpacing * 0.8),
              Expanded(
                child: _KpiCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: _progressColor(r.pctProgresoTotal / 100),
                  title: 'Progreso',
                  value: '${r.pctProgresoTotal.toStringAsFixed(1)}%',
                  subtitle: _progressLabel(r.pctProgresoTotal / 100),
                  progress: r.pctProgresoTotal / 100,
                ),
              ),
            ],
          ),
          SizedBox(height: context.mediumSpacing * 0.8),
          _KpiCard(
            icon: Icons.sync_rounded,
            iconColor: _kGreen,
            title: 'Actualizaciones de Hoy',
            value: r.actualizacionesHoy.toString(),
            subtitle: 'Predios sincronizados hoy en campo',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Color _progressColor(double p) {
    if (p >= 0.9) return _kGreen;
    if (p >= 0.6) return _kBlue;
    if (p >= 0.3) return _kOrange;
    return _kRed;
  }

  String _progressLabel(double p) {
    if (p >= 0.9) return 'Excelente ✓';
    if (p >= 0.7) return 'Buen ritmo';
    if (p >= 0.5) return 'A la mitad';
    return 'Requiere atención';
  }

  // ── Coberturas (Medidores, Alcantarillado) & GPS ───────────────────────────
  Widget _buildCoberturasGrid(
    BuildContext context,
    ColorScheme cs,
    DashboardStats stats,
  ) {
    final med = stats.coberturaMedidores;
    final alc = stats.coberturaAlcantarillado;
    final gps = stats.calidadGps;

    final double medTotal = (med.conMedidor + med.sinMedidor).toDouble();
    final double medPct = medTotal > 0
        ? (med.conMedidor / medTotal) * 100
        : 0.0;

    final double alcTotal = (alc.conAlcantarillado + alc.sinAlcantarillado)
        .toDouble();
    final double alcPct = alcTotal > 0
        ? (alc.conAlcantarillado / alcTotal) * 100
        : 0.0;

    // Color del GPS según su precisión promedio
    Color gpsColor = _kGreen;
    String gpsLabel = 'Excelente (<2.0m)';
    BadgeColorTheme badgeTheme = BadgeColorTheme.success;
    if (gps.precisionPromedio > 2.0 && gps.precisionPromedio <= 5.0) {
      gpsColor = _kOrange;
      gpsLabel = 'Buena (2.0m - 5.0m)';
      badgeTheme = BadgeColorTheme.warning;
    } else if (gps.precisionPromedio > 5.0) {
      gpsColor = _kRed;
      gpsLabel = 'Mejorable (>5.0m)';
      badgeTheme = BadgeColorTheme.danger;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.mediumSpacing * 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('COBERTURAS Y CALIDAD DE CAMPO'),
          SizedBox(height: context.smallSpacing * 1.5),

          // Medidores & Alcantarillado row
          Row(
            children: [
              Expanded(
                child: _CoverageCard(
                  title: 'Agua Potable',
                  subtitle: 'Con Medidor',
                  percentage: medPct,
                  countLabel: '${med.conMedidor} de ${medTotal.toInt()}',
                  activeColor: _kBlue,
                  icon: Icons.water_drop_rounded,
                ),
              ),
              SizedBox(width: context.mediumSpacing * 0.8),
              Expanded(
                child: _CoverageCard(
                  title: 'Alcantarillado',
                  subtitle: 'Con Cobertura',
                  percentage: alcPct,
                  countLabel: '${alc.conAlcantarillado} de ${alcTotal.toInt()}',
                  activeColor: _kTeal,
                  icon: Icons.waves_rounded,
                ),
              ),
            ],
          ),

          SizedBox(height: context.mediumSpacing * 0.8),

          // GPS Quality Card (Redesigned)
          Container(
            padding: EdgeInsets.all(context.mediumSpacing),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.15),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.smallSpacing * 1.2),
                  decoration: BoxDecoration(
                    color: gpsColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    color: gpsColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: context.mediumSpacing * 0.8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Precisión GPS Promedio',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CustomBadge(
                            label: gpsLabel,
                            theme: badgeTheme,
                            variant: BadgeVariant.light,
                            size: BadgeSize.small,
                            showIcon: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${gps.precisionPromedio.toStringAsFixed(2)}m',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: gpsColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'margen',
                      style: context.bodySmall.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
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

  // ── Zones Section ────────────────────────────────────────────────────────
  Widget _buildZonesSection(
    BuildContext context,
    ColorScheme cs,
    DashboardStats stats,
  ) {
    if (stats.porZonas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.smallSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('AVANCE POR ZONAS CATASTRALES'),
          SizedBox(height: context.smallSpacing * 1.5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.porZonas.length,
            separatorBuilder: (_, index) =>
                SizedBox(height: context.smallSpacing * 0.8),
            itemBuilder: (context, index) {
              final z = stats.porZonas[index];
              final double pct = z.total > 0 ? (z.completados / z.total) : 0.0;
              final color = _progressColor(pct);

              return Container(
                padding: EdgeInsets.all(context.mediumSpacing),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.map_rounded,
                            color: color,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: context.smallSpacing * 1.2),
                        Expanded(
                          child: Text(
                            'Zona Catastral ${z.zonaId}',
                            style: context.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '${z.completados}/${z.total}',
                          style: context.bodyMedium.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: context.mediumSpacing),
                        CustomBadge(
                          label: '${(pct * 100).toStringAsFixed(1)}%',
                          theme: pct >= 0.9
                              ? BadgeColorTheme.success
                              : (pct >= 0.6
                                    ? BadgeColorTheme.info
                                    : (pct >= 0.3
                                          ? BadgeColorTheme.warning
                                          : BadgeColorTheme.danger)),
                          variant: BadgeVariant.medium,
                          size: BadgeSize.small,
                          showIcon: false,
                        ),
                      ],
                    ),
                    SizedBox(height: context.mediumSpacing * 0.8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: cs.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    SizedBox(height: context.smallSpacing * 1.2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pendientes: ${z.pendientes}',
                                style: context.bodySmall.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: _kGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Completados: ${z.completados}',
                                style: context.bodySmall.copyWith(
                                  color: _kGreen,
                                  fontWeight: FontWeight.w700,
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
            },
          ),
        ],
      ),
    );
  }

  // ── Distributions Section ───────────────────────────────────────────────
  Widget _buildDistributionsSection(
    BuildContext context,
    ColorScheme cs,
    DashboardStats stats,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.mediumSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('DISTRIBUCIÓN DE PREDIOS'),
          SizedBox(height: context.smallSpacing * 1.5),

          // Categoría & Tarifa
          Column(
            children: [
              // Categorías
              _DistributionListCard(
                title: 'Por Categoría',
                icon: Icons.category_rounded,
                iconColor: _kGreen,
                items: stats.distribucion
                    .map(
                      (d) => _DistributionItem(
                        label: d.categoria,
                        count: d.cantidad,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: context.mediumSpacing * 0.8),
              // Tarifas
              _DistributionListCard(
                title: 'Por Tarifa',
                icon: Icons.receipt_long_rounded,
                iconColor: _kOrange,
                items: stats.distribucionTarifas
                    .map(
                      (t) =>
                          _DistributionItem(label: t.tarifa, count: t.cantidad),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Network Status and History Section ─────────────────────────────────────
  Widget _buildNetworkAndHistorySection(
    BuildContext context,
    ColorScheme cs,
    DashboardStats stats,
  ) {
    final net = stats.estadoRed;
    final double netTotal = (net.activas + net.inactivas).toDouble();
    final double activePct = netTotal > 0
        ? (net.activas / netTotal) * 100
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.mediumSpacing,
        vertical: context.smallSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('ESTADO DE LA RED Y TENDENCIA'),
          SizedBox(height: context.smallSpacing * 1.5),

          // Estado de Red Card
          Container(
            padding: EdgeInsets.all(context.mediumSpacing),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.15),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hub_rounded,
                        color: cs.primary,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: context.smallSpacing * 1.2),
                    Text(
                      'Estado de Acometidas en Red',
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    CustomBadge(
                      label: '${activePct.toStringAsFixed(1)}% Activas',
                      theme: activePct >= 90
                          ? BadgeColorTheme.success
                          : BadgeColorTheme.warning,
                      variant: BadgeVariant.medium,
                      size: BadgeSize.small,
                      showIcon: false,
                    ),
                  ],
                ),
                SizedBox(height: context.mediumSpacing),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: activePct / 100,
                    minHeight: 10,
                    backgroundColor: _kRed.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
                  ),
                ),
                SizedBox(height: context.mediumSpacing * 0.8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Activas: ${net.activas}',
                            style: context.bodySmall.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _kRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Inactivas: ${net.inactivas}',
                            style: context.bodySmall.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
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

          if (stats.historico.isNotEmpty) ...[
            SizedBox(height: context.mediumSpacing * 1.2),
            // Ultimos 5 dias de actividad
            Container(
              padding: EdgeInsets.all(context.mediumSpacing),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.15),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_toggle_off_rounded,
                          color: cs.primary,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: context.smallSpacing * 1.2),
                      Text(
                        'Historial de Actualización Reciente',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.mediumSpacing * 0.8),
                  const Divider(height: 1, thickness: 0.5),
                  SizedBox(height: context.smallSpacing),
                  Column(
                    children: stats.historico
                        .take(5)
                        .map(
                          (h) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: _kGreen,
                                  size: 18,
                                ),
                                SizedBox(width: context.smallSpacing * 1.2),
                                Text(
                                  h.fecha,
                                  style: context.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                CustomBadge(
                                  label: '+${h.registrosCompletados}',
                                  theme: BadgeColorTheme.info,
                                  variant: BadgeVariant.medium,
                                  size: BadgeSize.small,
                                  showIcon: false,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── KPI Card Component ─────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final double? progress;
  final bool fullWidth;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.progress,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(context.smallSpacing * 1.2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        SizedBox(height: context.smallSpacing * 1.2),
        Text(
          value,
          style: context.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: context.extraSmallSpacing * 0.4),
        Text(
          title,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.extraSmallSpacing * 1.2),
        CustomBadge(
          label: subtitle,
          theme: iconColor == _kGreen
              ? BadgeColorTheme.success
              : (iconColor == _kRed
                    ? BadgeColorTheme.danger
                    : (iconColor == _kOrange
                          ? BadgeColorTheme.warning
                          : BadgeColorTheme.info)),
          variant: BadgeVariant.light,
          size: BadgeSize.small,
          showIcon: false,
        ),
        if (progress != null) ...[
          SizedBox(height: context.smallSpacing),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: iconColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
        ],
      ],
    );

    if (fullWidth) {
      cardContent = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.smallSpacing * 1.4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          SizedBox(width: context.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.bodySmall.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          CustomBadge(
            label: value,
            theme: BadgeColorTheme.success,
            variant: BadgeVariant.heavy,
            size: BadgeSize.medium,
            showIcon: false,
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.mediumSpacing),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: cardContent,
    );
  }
}

// ── Coverage Card Component ────────────────────────────────────────────────
class _CoverageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percentage;
  final String countLabel;
  final Color activeColor;
  final IconData icon;

  const _CoverageCard({
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.countLabel,
    required this.activeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(context.mediumSpacing),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: activeColor, size: 16),
              SizedBox(width: context.extraSmallSpacing * 1.5),
              Text(
                title,
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: context.mediumSpacing),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 9,
                  backgroundColor: activeColor.withValues(alpha: 0.1),
                  color: activeColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: activeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: context.mediumSpacing),
          Text(
            subtitle,
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          SizedBox(height: context.extraSmallSpacing * 0.8),
          Text(
            countLabel,
            style: context.bodySmall.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Distribution List Card ────────────────────────────────────────────────
class _DistributionItem {
  final String label;
  final int count;
  _DistributionItem({required this.label, required this.count});
}

class _DistributionListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_DistributionItem> items;

  const _DistributionListCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final int total = items.fold(0, (sum, item) => sum + item.count);

    return Container(
      padding: EdgeInsets.all(context.largeSpacing),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              SizedBox(width: context.smallSpacing * 1.2),
              Expanded(
                child: Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.largeSpacing),
          const Divider(height: 2, thickness: 1),
          SizedBox(height: context.largeSpacing),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.largeSpacing),
              child: Center(
                child: Text(
                  'Sin datos',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ...items.map((item) {
              final double pct = total > 0 ? (item.count / total) : 0.0;
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.largeSpacing * 0.6,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.label,
                            style: context.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: cs.onSurface.withValues(alpha: 0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item.count.toString(),
                          style: context.bodySmall.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomBadge(
                          label: '${(pct * 100).toStringAsFixed(1)}%',
                          theme: iconColor == _kGreen
                              ? BadgeColorTheme.success
                              : BadgeColorTheme.warning,
                          variant: BadgeVariant.light,
                          size: BadgeSize.small,
                          showIcon: false,
                        ),
                      ],
                    ),
                    SizedBox(height: context.extraSmallSpacing * 1.2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: cs.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ── Avatar Button Component ───────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.person_rounded, color: cs.primary, size: 24),
        ),
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.bodySmall.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Error View Component ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.mediumSpacing * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: cs.onSurfaceVariant, size: 48),
            SizedBox(height: context.smallSpacing),
            Text(
              message,
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.mediumSpacing),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              onPressed: () => context.read<DashboardCubit>().refresh(),
            ),
          ],
        ),
      ),
    );
  }
}
