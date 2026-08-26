import 'package:app_properties/core/theme/app_theme.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_state.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/core/router/app_router.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';

// 1. RouteObserver global
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// 2. Determina el flavor desde --flavor o --dart-define
final String flavor = appFlavor ?? const String.fromEnvironment('FLAVOR', defaultValue: 'develop');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializar locale para fechas en español
  await initializeDateFormatting('es_ES', null);

  // 4. Carga el entorno correcto (API_URL desde .env.production o .env.dev)
  final envType = flavor == 'develop'
      ? EnvironmentType.dev
      : EnvironmentType.prod;
  await Environment.init(env: envType);

  // 5. Solo en dev: imprime config
  if (flavor == 'develop') {
    Environment.printConfig();
  }

  // 6. Inyección de dependencias
  await di.init();

  // 7. Inicializar tema persistido antes del primer frame
  await di.sl<ThemeCubit>().init();

  // 8. Ejecuta la app
  runApp(
    const ProviderScope(
      // ← Agrega esto
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LoginCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => di.sl<AddPropertyImageBloc>()),
        BlocProvider.value(value: di.sl<ThemeCubit>()),
      ],
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginInitial) {
            AppRouter.router.go('/login');
          } else if (state is LoginSuccess) {
            AppRouter.router.go('/home');
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'Predios EPAA-AA',
              debugShowCheckedModeBanner: flavor == 'develop',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
