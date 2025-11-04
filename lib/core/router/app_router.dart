import 'package:flutter/material.dart';
import 'package:app_properties/features/form/presentation/pages/location_screen.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:app_properties/features/observations/presentation/pages/observation_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/features/auth/presentation/pages/login_screen.dart';
import 'package:app_properties/features/home/presentation/pages/home_screen.dart';
import 'package:app_properties/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:app_properties/features/manually/presentation/pages/manual_entry_screen.dart';
import 'package:app_properties/features/scan/presentation/pages/scan_screen.dart';
import 'package:app_properties/features/form/presentation/pages/update_form_screen.dart'
    as form;
import 'package:app_properties/features/form/presentation/pages/view_data_screen.dart';
import 'package:app_properties/main.dart'; // Importa routeObserver

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [routeObserver], // <-- Añade RouteObserver aquí
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPage(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      // === RUTA: VER DATOS (solo lectura) ===
      GoRoute(
        path: '/view-data',
        builder: (context, state) {
          final extra = state.extra;

          if (extra == null || extra is! Map<String, dynamic>) {
            // Opcional: redirigir o mostrar error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: datos no proporcionados')),
              );
              context.go('/home');
            });
            return const SizedBox(); // Widget temporal
          }

          final data = extra['data'] as Map<String, dynamic>?;

          if (data == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: datos vacíos')),
              );
              context.go('/home');
            });
            return const SizedBox();
          }

          return ViewDataScreen(data: data);
        },
      ),
      // RUTA CORREGIDA CON IMPORT
      GoRoute(
        path: '/update-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final initialData = extra['data'] as Map<String, dynamic>;

          return form.UpdateFormScreen(data: initialData);
        },
      ),
      GoRoute(
        path: '/manually-entry',
        builder: (context, state) => BlocProvider(
          create: (context) => di.sl<ManuallyBloc>(),
          child: const ManualEntryScreen(),
        ),
      ),
      GoRoute(
        path: '/observations',
        builder: (context, state) {
          final connectionId = state.extra as String?; // <-- opcional
          final bloc = di.sl<ObservationBloc>();
          bloc.add(FindAllObservationsEvent());
          return BlocProvider.value(
            value: bloc,
            child: ObservationPage(connectionId: connectionId ?? ''),
          );
        },
      ),
    ],
  );
}
