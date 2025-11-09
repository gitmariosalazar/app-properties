import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/di/injection.dart' as di;
import 'package:app_properties/core/router/app_router.dart';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/features/auth/presentation/bloc/auth_bloc.dart';

// 1. RouteObserver global
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// 2. Determina el flavor desde --dart-define
const String _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'prod');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Carga el entorno correcto (API_URL desde assets/.env)
  final envType = _flavor == 'dev' ? EnvironmentType.dev : EnvironmentType.prod;
  await Environment.init(env: envType);

  // 4. Solo en dev: imprime config
  if (_flavor == 'dev') {
    Environment.printConfig();
  }

  // 5. Inyección de dependencias
  await di.init();

  // 6. Ejecuta la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<AddPropertyImageBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Scan App',
        debugShowCheckedModeBanner: _flavor == 'dev', // Solo en dev
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
