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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.background,
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
                      color: Colors.white,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.12),
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(isTablet ? 28 : 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: Image.asset(
                            'assets/images/property.png',
                            height: logoSize + 24,
                            width: logoSize + 24,
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
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(
                        context.largeBorderRadiusValue,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.04),
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
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Menu Buttons in a Card with some separation
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: BorderRadius.circular(
                        context.largeBorderRadiusValue,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: buttonSpacing / 1.2,
                      horizontal: isTablet ? 18 : 10,
                    ),
                    child: Column(
                      children: [
                        _AnimatedMenuButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Escanear QR',
                          color: theme.colorScheme.primary,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.92),
                              theme.colorScheme.primary.withOpacity(0.78),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onPressed: () => context.push('/scan'),
                        ),
                        SizedBox(height: buttonSpacing),
                        _AnimatedMenuButton(
                          icon: Icons.search_rounded,
                          label: 'Buscar Acometida',
                          color: Colors.deepPurple,
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.indigoAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onPressed: () => context.push('/manually-entry'),
                        ),
                        //SizedBox(height: buttonSpacing),
                        /*
                        _AnimatedMenuButton(
                          icon: Icons.note_alt_rounded,
                          label: 'Ver Observaciones',
                          color: theme.colorScheme.secondary,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.secondary.withOpacity(0.95),
                              Colors.orangeAccent.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onPressed: () => context.push('/observations'),
                        ),
                        */
                      ],
                    ),
                  ),
                  SizedBox(height: buttonSpacing * 1.1),
                  // Footer
                  Opacity(
                    opacity: 0.65,
                    child: Text(
                      'Rápido. Seguro. Simple.',
                      style: context.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: isTablet ? 38 : 18),
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
                color: widget.color.withOpacity(0.18),
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
