import 'package:app_properties/features/home/presentation/pages/shell_navigator.dart';
import 'package:app_properties/features/profile/presentation/pages/profile_screen.dart';
import 'package:app_properties/features/properties/search/presentation/manually/blocs/index.dart';
import 'package:app_properties/features/properties/search/presentation/scan/pages/scan_screen.dart';
import 'package:app_properties/features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/main.dart';

// === PANTALLAS ===
import 'package:app_properties/features/auth/presentation/pages/login_screen.dart';
import 'package:app_properties/features/home/presentation/pages/home_screen.dart';
import 'package:app_properties/features/properties/form/presentation/screen/update_form_screen.dart';
import 'package:app_properties/features/observations/presentation/pages/observation_page.dart';
import 'package:app_properties/features/properties/search/presentation/manually/pages/manually_screen.dart';
import 'package:app_properties/features/properties/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:app_properties/features/properties/search/presentation/info/pages/SearchConnectionPage.dart';
import 'package:app_properties/features/properties/search/presentation/info/cubit/search_connection_cubit.dart';
import 'package:app_properties/features/properties/form/presentation/screen/detail_page.dart';

import 'package:app_properties/features/properties/search/presentation/offline/pages/offline_preload_screen.dart';

// === BLOCs ===
import 'package:app_properties/features/properties/search/presentation/scan/blocs/connection_with_properties_bloc.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';

// === ENTIDADES ===
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [routeObserver],
    redirect: (context, state) {
      if (state.uri.path == '/') return '/login';
      return null;
    },
    routes: [
      // === LOGIN (sin shell) ===
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // === SHELL: rutas con bottom nav ===
      ShellRoute(
        builder: (context, state, child) => ShellNavigator(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/manually-entry-properties',
            builder: (context, state) => BlocProvider(
              create: (context) =>
                  di.sl<ManuallyConnectionWithPropertiesBloc>(),
              child: const ManualEntryConnectionWithPropertiesScreen(),
            ),
          ),
          GoRoute(
            path: '/search-connection',
            builder: (context, state) => BlocProvider(
              create: (context) => di.sl<SearchConnectionCubit>(),
              child: const SearchConnectionPage(),
            ),
          ),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),

      // === RUTAS FULL-SCREEN (sin bottom nav) ===
      GoRoute(
        path: '/property-scan',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => di.sl<ConnectionWithPropertiesBloc>(),
            child: const PropertyScanPage(),
          );
        },
      ),
      GoRoute(
        path: '/update-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null ||
              !extra.containsKey('connection') ||
              extra['connection'] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Datos de conexión no proporcionados'),
                  backgroundColor: Colors.red,
                ),
              );
              context.go('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final connectionData = extra['connection'];
          final mode = extra['mode'] as String? ?? 'manual';

          if (connectionData is! ConnectionWithPropertiesEntity) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Tipo de datos de conexión inválido'),
                  backgroundColor: Colors.red,
                ),
              );
              context.go('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return UpdateConnectionFormScreen(
            connection: connectionData,
            mode: mode,
          );
        },
      ),
      GoRoute(
        path: '/detail-page',
        builder: (context, state) {
          final cadastralKey = state.extra as String? ?? '';
          return DetailPage(cadastralKey: cadastralKey);
        },
      ),

      // === OBSERVACIONES ===
      GoRoute(
        path: '/observations',
        builder: (context, state) {
          final connectionId = state.extra as String? ?? '';
          final bloc = di.sl<ObservationBloc>()
            ..add(FindAllObservationsEvent());
          return BlocProvider.value(
            value: bloc,
            child: ObservationPage(connectionId: connectionId),
          );
        },
      ),

      // === PERFIL ===
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/offline-preload',
        builder: (context, state) => const OfflinePreloadScreen(),
      ),
    ],
  );
}
