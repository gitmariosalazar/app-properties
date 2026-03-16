import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/auth/domain/entities/user.dart';
import 'package:app_properties/utils/responsive_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: context.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: isTablet ? 28 : 22),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginInitial) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is LoginSuccess) {
            final user = state.user;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(user: user),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48.0 : 24.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información Personal',
                          style: context.titleMedium.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          icon: Icons.person_outline,
                          title: 'Nombre Completo',
                          value: '${user.firstName} ${user.lastName}',
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          icon: Icons.email_outlined,
                          title: 'Correo Electrónico',
                          value: user.email,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          icon: Icons.badge_outlined,
                          title: 'Nombre de Usuario',
                          value: user.username,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          icon: Icons.verified_user_outlined,
                          title: 'Roles',
                          value: user.roles.join(', '),
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 40),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 60 : 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showLogoutConfirmation(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.red.shade200),
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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

          if (state is LoginLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fallback if not logged in (though middleware should handle this)
          return Center(
            child: Text('No hay sesión activa', style: context.bodyLarge),
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<LoginCubit>().logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;

    return Container(
      color: theme.colorScheme.primary,
      padding: EdgeInsets.only(
        bottom: isTablet ? 40 : 30,
        top: isTablet ? 20 : 10,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: isTablet ? 60 : 50,
            backgroundColor: Colors.white,
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: isTablet ? 48 : 36,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: context.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.isActive ? 'Activo' : 'Inactivo',
              style: context.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isTablet;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 8 : 4,
        ),
      ),
    );
  }
}
