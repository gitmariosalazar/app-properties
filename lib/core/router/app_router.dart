import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/home/presentation/pages/shell_navigator.dart';
import 'package:app_properties/features/profile/presentation/pages/profile_screen.dart';
import 'package:app_properties/features/properties/search/presentation/manually/blocs/index.dart';
import 'package:app_properties/features/properties/search/presentation/scan/pages/scan_screen.dart';
import 'package:app_properties/features/public/presentation/cubit/public_incidents_map_cubit.dart';
import 'package:app_properties/features/public/presentation/pages/public_incidents_dashboard_screen.dart';
import 'package:app_properties/features/public/presentation/pages/public_incidents_map_screen.dart';
import 'package:app_properties/features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

import 'package:app_properties/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:app_properties/features/incidents/presentation/page/create_incident_form.dart';
import 'package:app_properties/features/incidents/presentation/page/incident_history_page.dart';
import 'package:app_properties/features/incidents/presentation/pages/solve_incident_screen.dart';
import 'package:app_properties/features/incidents/presentation/pages/solve_and_changemeter_incident_screen.dart';
import 'package:app_properties/features/reading/domain/usecases/get_reading_info.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: di.sl<SharedPreferences>().getString('CACHED_AUTH_TOKEN') != null ? '/home' : '/login',
    observers: [routeObserver],
    redirect: (context, state) {
      final authState = di.sl<LoginCubit>().state;
      final isAuthenticated = authState is LoginSuccess;

      if (state.uri.path == '/') {
        return isAuthenticated ? '/home' : '/login';
      }

      if (state.uri.path == '/login' && isAuthenticated) {
        return '/home';
      }

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

      // INCIDENTS
      GoRoute(
        path: '/create-incident',
        builder: (context, state) {
          final connectionId = state.extra as String?;
          return BlocProvider(
            create: (_) => di.sl<IncidentCubit>(),
            child: CreateIncidentForm(
              connectionId: connectionId ?? '',
              getReadingInfo: (id) => di.sl<GetReadingInfo>().call(id),
            ),
          );
        },
      ),
      GoRoute(
        path: '/incidents-history',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<IncidentCubit>(),
          child: const IncidentHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/solve-incident',
        builder: (context, state) {
          final incidentData = state.extra as Map<String, dynamic>;
          final incidentId = incidentData['incidentId'] as String;
          final incidentCode = incidentData['incidentCode'] as String;
          return BlocProvider(
            create: (_) => di.sl<IncidentCubit>(),
            child: SolveIncidentScreen(
              incidentId: incidentId,
              incidentCode: incidentCode,
            ),
          );
        },
      ),
      GoRoute(
        path: '/solve-and-change-meter',
        builder: (context, state) {
          final incidentData = state.extra as Map<String, dynamic>;
          final incidentId = incidentData['incidentId'] as String;
          final incidentCode = incidentData['incidentCode'] as String;
          final connectionId = incidentData['connectionId'] as String?;
          return BlocProvider(
            create: (_) => di.sl<IncidentCubit>(),
            child: SolveAndChangeMeterIncidentScreen(
              incidentId: incidentId,
              incidentCode: incidentCode,
              connectionId: connectionId,
            ),
          );
        },
      ),

      GoRoute(
        path: '/public-incidents-dashboard',
        builder: (context, state) => const PublicIncidentsDashboardScreen(),
      ),
      GoRoute(
        path: '/public-incidents-map',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<PublicIncidentsMapCubit>()..loadMapIncidents(),
          child: const PublicIncidentsMapScreen(),
        ),
      ),
    ],
  );
}
