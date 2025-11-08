import 'package:app_properties/features/properties/list/presentation/manually/blocs/index.dart';
import 'package:app_properties/features/properties/list/presentation/scan/pages/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/main.dart';

// === PANTALLAS ===
import 'package:app_properties/features/auth/presentation/pages/login_screen.dart';
import 'package:app_properties/features/home/presentation/pages/home_screen.dart';
import 'package:app_properties/features/manually/presentation/pages/manual_entry_screen.dart';
import 'package:app_properties/features/form/presentation/pages/view_data_screen.dart';
import 'package:app_properties/features/properties/form/presentation/screen/update_form_screen.dart';
import 'package:app_properties/features/observations/presentation/pages/observation_page.dart';

import 'package:app_properties/features/properties/list/presentation/manually/pages/manually_screen.dart';

// === BLOCs ===
import 'package:app_properties/features/properties/list/presentation/scan/blocs/connection_with_properties_bloc.dart';
import 'package:app_properties/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';

// === ENTIDADES ===
import 'package:app_properties/features/properties/list/domain/entities/connection.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [routeObserver],
    routes: [
      // === LOGIN ===
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // === HOME ===
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // === ESCANEAR QR (CORRECTO) ===
      GoRoute(
        path: '/property-scan',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => di.sl<ConnectionWithPropertiesBloc>(),
            child: const PropertyScanPage(),
          );
        },
      ),
      /*
      // === ENTRADA MANUAL ===
      GoRoute(
        path: '/manually-entry',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<ManuallyBloc>(),
          child: const ManualEntryScreen(),
        ),
      ),
*/
      // === VER DATOS (solo lectura) ===
      GoRoute(
        path: '/view-data',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null || !extra.containsKey('data')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: datos no proporcionados')),
              );
              context.go('/home');
            });
            return const SizedBox.shrink();
          }

          return ViewDataScreen(data: extra['data'] as Map<String, dynamic>);
        },
      ),

      // === EDITAR FORMULARIO ===
      GoRoute(
        path: '/update-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          // Validar que extra no sea null y tenga 'connection'
          if (extra == null ||
              !extra.containsKey('connection') ||
              extra['connection'] == null) {
            // Mostrar error y redirigir
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

          final connection = extra['connection'] as ConnectionEntity;
          final mode = extra['mode'] as String? ?? 'manual';

          return BlocProvider(
            create: (_) => di.sl<ConnectionWithPropertiesBloc>(),
            child: UpdateConnectionFormScreen(
              connection: connection,
              mode: mode,
            ),
          );
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

      GoRoute(
        path: '/manually-entry-properties',
        builder: (context, state) => BlocProvider(
          create: (context) => di.sl<ManuallyConnectionWithPropertiesBloc>(),
          child: const ManualEntryConnectionWithPropertiesScreen(),
        ),
      ),
    ],
  );
}
