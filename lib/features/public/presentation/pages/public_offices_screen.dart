import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicOfficesScreen extends StatelessWidget {
  const PublicOfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceBright,
      appBar: AppBar(
        title: const Text('Puntos de Pago / Oficinas'),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOfficeCard(context, colors),
              const SizedBox(height: 32),
              _buildCompanyInfoSection(context, colors),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Office Info Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.domain_rounded, color: colors.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Oficinas Matriz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _ContactRow(
                  icon: Icons.phone_rounded,
                  label: 'Teléfono:',
                  value: '(06) 290-6823 Ext.101',
                  onTap: () => _makePhoneCall('062906823'),
                  colors: colors,
                ),
                const SizedBox(height: 16),
                _ContactRow(
                  icon: Icons.location_on_rounded,
                  label: 'Dirección:',
                  value:
                      'Bolívar y González Suárez Esquina\nAtuntaqui – Antonio Ante',
                  colors: colors,
                  isMultiline: true,
                ),
              ],
            ),
          ),

          // Map Section
          const _MapPreviewSection(),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoSection(BuildContext context, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Misión & Visión
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            if (isSmallScreen) {
              return Column(
                children: [
                  _buildInfoCard(
                    context,
                    colors,
                    icon: Icons.track_changes_rounded,
                    title: 'MISIÓN',
                    content:
                        'Dotar de los servicios de agua potable y alcantarillado con calidad, eficiencia e innovación y de atención inmediata con mejoras continuas, beneficiando a todos los hogares del cantón Antonio Ante.',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    colors,
                    icon: Icons.rocket_launch_rounded,
                    title: 'VISIÓN',
                    content:
                        'Ser una empresa referente a nivel provincial en la optimización del modelo de gestión del recurso hídrico y de alcantarillado, a través de la prestación de servicios ágiles, oportunos, continuos y de calidad, en beneficio de todos los habitantes del cantón Antonio Ante.',
                  ),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      colors,
                      icon: Icons.track_changes_rounded,
                      title: 'MISIÓN',
                      content:
                          'Dotar de los servicios de agua potable y alcantarillado con calidad, eficiencia e innovación y de atención inmediata con mejoras continuas, beneficiando a todos los hogares del cantón Antonio Ante.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      colors,
                      icon: Icons.rocket_launch_rounded,
                      title: 'VISIÓN',
                      content:
                          'Ser una empresa referente a nivel provincial en la optimización del modelo de gestión del recurso hídrico y de alcantarillado, a través de la prestación de servicios ágiles, oportunos, continuos y de calidad, en beneficio de todos los habitantes del cantón Antonio Ante.',
                    ),
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 32),

        // Valores Title
        Center(
          child: Column(
            children: [
              Text(
                'Nuestros Valores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Valores Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isSmallScreen ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildValorCard(
                  context,
                  colors,
                  Icons.check_circle_outline_rounded,
                  'Calidad',
                  'Excelencia en cada gota de agua.',
                ),
                _buildValorCard(
                  context,
                  colors,
                  Icons.autorenew_rounded,
                  'Eficiencia',
                  'Optimización de recursos hídricos.',
                ),
                _buildValorCard(
                  context,
                  colors,
                  Icons.lightbulb_outline_rounded,
                  'Innovación',
                  'Tecnología al servicio del ciudadano.',
                ),
                _buildValorCard(
                  context,
                  colors,
                  Icons.handshake_outlined,
                  'Compromiso',
                  'Atención inmediata y continua.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ColorScheme colors, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValorCard(
    BuildContext context,
    ColorScheme colors,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.primary, size: 28),
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
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final VoidCallback? onTap;
  final bool isMultiline;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    this.onTap,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: isMultiline
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: isMultiline
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    )
                  : RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: '$label ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                          TextSpan(text: value),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewSection extends StatelessWidget {
  static const double _latitude = 0.332304;
  static const double _longitude = -78.214488;

  const _MapPreviewSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(_latitude, _longitude),
                zoom: 16.5,
              ),
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              markers: {
                const Marker(
                  markerId: MarkerId('oficina_matriz'),
                  position: LatLng(_latitude, _longitude),
                  infoWindow: InfoWindow(
                    title: 'EPAA-AA',
                    snippet: 'Empresa Pública de Agua Potable y Alcantarillado',
                  ),
                ),
              },
            ),
          ),

          // "Abrir en Maps" Floating Button overlay
          Positioned(
            top: 12,
            left: 12,
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              elevation: 4,
              child: InkWell(
                onTap: () => _openInMaps(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Abrir en Maps',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // We removed the transparent overlay so the user can interact (zoom/pan) with the map.
        ],
      ),
    );
  }

  Future<void> _openInMaps() async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }
}
