import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;
    final logoSize = isTablet ? 180.0 : 120.0;
    final buttonSpacing = isTablet
        ? context.largeSpacing
        : context.mediumSpacing;
    final sidePadding = isTablet ? 56.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scanner App',
          style: context.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: isTablet ? 12.0 : 0),
          child: IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(Icons.home_rounded, size: isTablet ? 34 : 28),
            tooltip: "Inicio",
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isTablet ? 12.0 : 8.0),
            child: IconButton(
              onPressed: () => context.push('/profile'),
              icon: Icon(Icons.person_rounded, size: isTablet ? 34 : 28),
              tooltip: "Mi Perfil",
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Scanner Logo with nice circle and shadow
                  Container(
                    margin: EdgeInsets.only(
                      bottom: buttonSpacing * 1.2,
                      top: buttonSpacing * 1.3,
                    ),
                    child: Material(
                      elevation: 5,
                      shape: const CircleBorder(),
                      color: theme.colorScheme.surfaceContainerHighest,
                      shadowColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(isTablet ? 28 : 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: Image.asset(
                            'assets/images/property.png',
                            height: logoSize - 30,
                            width: logoSize - 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.qr_code_scanner,
                              size: logoSize,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic welcome card
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(
                        context.largeBorderRadiusValue,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 32 : 20,
                      horizontal: sidePadding / 2,
                    ),
                    margin: EdgeInsets.only(bottom: buttonSpacing * 1.3),
                    child: Column(
                      children: [
                        Text(
                          '¡Bienvenido a Scanner EPAA-AA!',
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        context.vSpace(0.007),
                        Text(
                          'Actualización de datos de Predios y Catastro mediante escaneo de códigos QR.',
                          style: context.bodyLarge.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const _SectionTitle('Actualización de Predios'),
                  const SizedBox(height: 12),

                  _ActionCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Escanear QR',
                    subtitle:
                        'Escanea el código QR de un predio para acceder a su información y actualizar datos',
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/property-scan'),
                  ),
                  const SizedBox(height: 12),

                  _ActionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Buscar Predio Manualmente',
                    subtitle:
                        'Busca y accede a un predio mediante su código de conexión o número de predio para actualizar datos',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E35B1), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/manually-entry-properties'),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Actualizar número de medidor',
                    subtitle:
                        'Busca y accede a un predio mediante su código de conexión o número de predio para actualizar el número de medidor',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5E35B1), Color(0xFF7C4DFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/update-connection-number'),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Información de Acometidas y Medidores'),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.cable,
                    enable: true,
                    title: 'Buscar Acometidas',
                    subtitle:
                        'Accede a información de acometidas y medidores de predios registrados',
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 12, 100, 0),
                        Color.fromARGB(169, 29, 193, 0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/search-connection'),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Gestión de Incidencias'),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.report,
                    enable: true,
                    title: 'Reportar Incidencia',
                    subtitle:
                        'Registra anomalías en la acometida o medidor y alcantarillado',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/create-incident'),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.history_toggle_off_rounded,
                    enable: true,
                    title: 'Historial de Incidencias',
                    subtitle: 'Consulta el estado de los incidentes reportados',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF37474F), Color(0xFF78909C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/incidents-history'),
                  ),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.map_rounded,
                    enable: true,
                    title: 'Mapa de Incidencias',
                    subtitle: 'Ver el mapa con la ubicación de las incidencias',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00796B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/public-incidents-map'),
                  ),
                  const SizedBox(height: 12),

                  _ActionCard(
                    icon: Icons.dashboard,
                    enable: true,
                    title: 'Dashboard de Incidencias',
                    subtitle: 'Ver el dashboard de las incidencias',
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 132, 197),
                        Color.fromARGB(255, 32, 179, 247),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => context.push('/public-incidents-dashboard'),
                  ),
                  const SizedBox(height: 32),

                  const Center(
                    child: Text(
                      'Empresa Pública de Agua Potable y Alcantarillado de Antonio Ante\nEPAA-AA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Menu Button with gradient, shadow, scaling animation and nice UX
class _AnimatedMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final VoidCallback onPressed;

  const _AnimatedMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onPressed,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.07,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final iconSize = isTablet ? 36.0 : 26.0;
    final fontSize = isTablet ? 22.0 : 17.0;
    final buttonHeight = isTablet ? 70.0 : 56.0;
    final borderRadius = context.mediumBorderRadiusValue * 2.2;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.18),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: widget.onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: iconSize, color: Colors.white),
                  SizedBox(width: context.mediumSpacing * 0.7),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool enable;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.enable = true,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enable;

    return GestureDetector(
      // Block all gestures when disabled
      onTapDown: isEnabled ? (_) => _ctrl.forward() : null,
      onTapUp: isEnabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: isEnabled ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: isEnabled ? _scale.value : 1.0,
          child: child,
        ),
        child: Opacity(
          // Fade disabled cards
          opacity: isEnabled ? 1.0 : 0.45,
          child: Stack(
            children: [
              // ── Card body ──────────────────────────────────────────
              ColorFiltered(
                // Desaturate completely when disabled
                colorFilter: isEnabled
                    ? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.color,
                      )
                    : const ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.80),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // ── "Próximamente" badge (only when disabled) ──────────
              if (!isEnabled)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.40),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'Próximamente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
