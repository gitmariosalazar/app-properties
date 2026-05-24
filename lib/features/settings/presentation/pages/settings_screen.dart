// lib/features/settings/presentation/pages/settings_screen.dart
//
// Clean Architecture: Presentation layer — reads LoginCubit and ThemeCubit.
// SOLID: Each private widget has a single responsibility.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoginCubit>().state;
    final user = loginState is LoginSuccess ? loginState.user : null;
    final isDark = context.watch<ThemeCubit>().isDark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Configuración'),
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: cs.outline, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Profile banner ────────────────────────────────────────
          if (user != null)
            _buildProfileCard(
              user.firstName,
              user.lastName,
              user.email,
              user.roles,
            ),

          // ── General section ───────────────────────────────────────
          const _SectionHeader('General'),
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                        : const Color(0xFF1A2035).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 20,
                    color: isDark
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF1A2035),
                  ),
                ),
                title: Text(
                  isDark ? 'Modo oscuro' : 'Modo claro',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isDark
                      ? 'Interfaz en tono oscuro'
                      : 'Interfaz en tono claro',
                  style: const TextStyle(fontSize: 12),
                ),
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                activeTrackColor: isDark
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF1A2035),
                activeThumbColor: Colors.white,
                inactiveTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.15),
                inactiveThumbColor: Colors.white,
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(
                      alpha: isDark ? 0.20 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 20,
                    color: Color(0xFF1565C0),
                  ),
                ),
                title: const Text(
                  'Notificaciones',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Alertas de predios y novedades',
                  style: TextStyle(fontSize: 12),
                ),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
                activeTrackColor: const Color(0xFF1565C0),
                activeThumbColor: Colors.white,
                inactiveTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.15),
                inactiveThumbColor: Colors.white,
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.security_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                title: 'Estado de seguridad',
                subtitle: 'Verificar estado de autenticación',
                onTap: () => _showSecurityStatus(context),
              ),
            ],
          ),

          // ── Organización section ──────────────────────────────────
          const _SectionHeader('Organización'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF1565C0),
                iconBg: const Color(0xFFE3F2FD),
                title: 'Mi Perfil',
                subtitle: 'Ver y editar información personal',
                onTap: () => context.push('/profile'),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFF6A1B9A),
                iconBg: const Color(0xFFF3E5F5),
                title: 'EPAA-AA',
                subtitle:
                    'Empresa de Agua Potable y Alcantarillado de Antonio Ante',
                trailing: null,
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.map_rounded,
                iconColor: const Color(0xFF00695C),
                iconBg: const Color(0xFFE0F2F1),
                title: 'Gestión de Predios',
                subtitle: 'Administración de predios y acometidas',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFE65100),
                iconBg: const Color(0xFFFFF3E0),
                title: 'Período Catastral',
                subtitle: 'Período activo y fechas de actualización',
                onTap: () {},
              ),
            ],
          ),

          // ── Aplicación section ────────────────────────────────────
          const _SectionHeader('Aplicación'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.qr_code_scanner_rounded,
                iconColor: const Color(0xFF1565C0),
                iconBg: const Color(0xFFE3F2FD),
                title: 'Escaneo QR',
                subtitle: 'Acceder rápido a predios por código QR',
                onTap: () => context.push('/property-scan'),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.file_download_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBg: const Color(0xFFE8F5E9),
                title: 'Exportar Datos',
                subtitle: 'Exportar predios en formato CSV/PDF',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFF5D4037),
                iconBg: const Color(0xFFEFEBE9),
                title: 'Sincronización',
                subtitle: 'Configurar sincronización offline',
                onTap: () {},
              ),
            ],
          ),

          // ── Soporte section ───────────────────────────────────────
          const _SectionHeader('Soporte'),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.help_rounded,
                iconColor: const Color(0xFF1565C0),
                iconBg: const Color(0xFFE3F2FD),
                title: 'Ayuda y Comentarios',
                subtitle: 'Guía de uso y soporte técnico',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.info_rounded,
                iconColor: const Color(0xFF607D8B),
                iconBg: const Color(0xFFECEFF1),
                title: 'Acerca de la aplicación',
                subtitle: 'Versión 1.0.0 · EPAA-AA © 2026',
                onTap: () => _showAbout(context),
              ),
            ],
          ),

          // ── Sign out ──────────────────────────────────────────────
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFC62828),
                  iconBg: const Color(0xFFFFEBEE),
                  title: 'Cerrar sesión',
                  titleColor: const Color(0xFFC62828),
                  subtitle: user != null
                      ? '${user.firstName} ${user.lastName}'
                      : 'Sesión activa',
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    String firstName,
    String lastName,
    String email,
    List<String> roles,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$firstName $lastName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (roles.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roles.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }

  void _showSecurityStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Estado de seguridad'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SecurityItem(
              icon: Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              label: 'Sesión autenticada con JWT',
            ),
            SizedBox(height: 8),
            _SecurityItem(
              icon: Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              label: 'Conexión segura HTTPS',
            ),
            SizedBox(height: 8),
            _SecurityItem(
              icon: Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              label: 'Datos almacenados de forma segura',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Predios EPAA-AA',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 EPAA-AA · Antonio Ante, Ecuador',
      children: const [
        SizedBox(height: 12),
        Text(
          'Sistema de gestión de predios y acometidas de agua potable para la Empresa de Agua Potable y Alcantarillado de Antonio Ante.',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  void _confirmSignOut(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión? Se perderá la sesión activa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.titleColor,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: titleColor ?? cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _SecurityItem({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
