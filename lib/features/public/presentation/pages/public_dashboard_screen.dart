import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';

class PublicDashboardScreen extends StatelessWidget {
  const PublicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
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
                color: colors.primary.withOpacity(isDark ? 0.2 : 0.1),
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
                color: colors.secondary.withOpacity(isDark ? 0.2 : 0.1),
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido a',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'EPAA-AA',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            // Theme toggle button
                            Container(
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: colors.primary,
                                ),
                                onPressed: () {
                                  context.read<ThemeCubit>().toggleTheme();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Portal Ciudadano',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login Card (Call to Action)
                        BlocBuilder<LoginCubit, LoginState>(
                          builder: (context, state) {
                            if (state is LoginSuccess) {
                              return _buildGoToPanelCard(context, colors);
                            }
                            return _buildLoginCard(context, colors);
                          },
                        ),

                        const SizedBox(height: 36),

                        Text(
                          'Servicios Públicos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Grid of Services
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: [
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Reportar\nIncidencia',
                              subtitle: 'Fugas y daños',
                              icon: Icons.report_problem_rounded,
                              iconColor: Colors.redAccent,
                              onTap: () => context.push('/create-incident'),
                            ),
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Consultar\nPlanilla',
                              subtitle: 'Tus comprobantes',
                              icon: Icons.receipt_long_rounded,
                              iconColor: Colors.blueAccent,
                              onTap: () {
                                context.push('/public-search-readings');
                              },
                            ),
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Puntos de\nPago',
                              subtitle: 'Nuestras oficinas',
                              icon: Icons.location_on_rounded,
                              iconColor: Colors.teal,
                              onTap: () {
                                context.push('/public-offices');
                              },
                            ),
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Dashboard\nIncidentes',
                              subtitle: 'Estadísticas',
                              icon: Icons.dashboard_rounded,
                              iconColor: Colors.purpleAccent,
                              onTap: () {
                                context.push('/public-incidents-dashboard');
                              },
                            ),
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Mapa de\nIncidencias',
                              subtitle: 'En tiempo real',
                              icon: Icons.map_rounded,
                              iconColor: Colors.indigoAccent,
                              onTap: () {
                                context.push('/public-incidents-map');
                              },
                            ),
                            _buildServiceCard(
                              context,
                              colors,
                              title: 'Comunicados\nOficiales',
                              subtitle: 'Noticias y más',
                              icon: Icons.campaign_rounded,
                              iconColor: Colors.orangeAccent,
                              onTap: () {
                                _showComingSoon(context, colors);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Footer
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop_rounded,
                                color: colors.primary.withOpacity(0.5),
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Empresa Pública de Agua Potable y Alcantarillado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant.withOpacity(
                                    0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Antonio Ante',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurfaceVariant.withOpacity(
                                    0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoToPanelCard(BuildContext context, ColorScheme colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                      '¡Hola de nuevo!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ya has iniciado sesión. Ve a tu panel para gestionar tus servicios.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onPrimaryContainer.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/inicio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Ir a mi Panel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: colors.primary,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, ColorScheme colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                      '¿Eres Usuario?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para gestionar tus medidores y ver tu historial completo.',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onPrimaryContainer.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 40,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ColorScheme colors, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceContainerHighest),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, ColorScheme colors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.build_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Funcionalidad en construcción. ¡Próximamente!'),
            ),
          ],
        ),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
