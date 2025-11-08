import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === AUTH ===
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/presentation/bloc/auth_bloc.dart';

// === OBSERVATIONS ===
import 'package:app_properties/features/observations/data/datasources/observations_datasource.dart';
import 'package:app_properties/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:app_properties/features/observations/domain/repositories/observation_repository.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';

// === CONNECTION WITH PROPERTIES (CRÍTICO) ===
import 'package:app_properties/features/properties/list/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:app_properties/features/properties/list/data/repositories/connection_with_properties_repository_impl.dart';
import 'package:app_properties/features/properties/list/domain/repositories/connection_with_properties_repository.dart';
import 'package:app_properties/features/properties/list/domain/usecases/get_connection_with_properties.dart';
import 'package:app_properties/features/properties/list/presentation/scan/blocs/connection_with_properties_bloc.dart';
import 'package:app_properties/features/properties/list/presentation/manually/blocs/index.dart';

import 'package:http/http.dart' as http;

// ... todos los imports ...

final sl = GetIt.instance;

Future<void> init() async {
  // ====================
  // EXTERNAL
  // ====================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ====================
  // AUTH
  // ====================
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // ====================
  // SCAN
  // ====================

  // ====================
  // FORM
  // ====================

  // ====================
  // MANUALLY
  // ====================
  sl.registerFactory(() => ManuallyConnectionWithPropertiesBloc(sl()));

  // ====================
  // OBSERVATIONS
  // ====================
  sl.registerLazySingleton<ObservationsDataSource>(
    () => ObservationsDataSourceImpl(),
  );
  sl.registerLazySingleton<ObservationRepository>(
    () => ObservationRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<FindAllObservationsUseCase>(
    () => FindAllObservationsUseCase(sl()),
  );
  sl.registerLazySingleton<FindAllObservationsByCadastralKeyUseCase>(
    () => FindAllObservationsByCadastralKeyUseCase(sl()),
  );
  sl.registerFactory(
    () => ObservationBloc(
      sl<FindAllObservationsUseCase>(),
      sl<FindAllObservationsByCadastralKeyUseCase>(),
    ),
  );

  // ====================
  // PHOTO READING
  // ====================
  // ====================
  // CONNECTION WITH PROPERTIES (CORREGIDO)
  // ====================

  // 1. HTTP CLIENT
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // 2. DATA SOURCE → PASA http.Client
  sl.registerLazySingleton<RemoteConnectionWithPropertiesDataSource>(
    () => RemoteConnectionWithPropertiesDataSourceImpl(sl<http.Client>()),
  );

  // 3. REPOSITORIO
  sl.registerLazySingleton<ConnectionWithPropertiesRepository>(
    () => ConnectionWithPropertiesRepositoryImpl(
      sl<RemoteConnectionWithPropertiesDataSource>(),
    ),
  );

  // 4. USE CASE
  sl.registerLazySingleton<GetConnectionWithProperties>(
    () => GetConnectionWithProperties(sl<ConnectionWithPropertiesRepository>()),
  );

  // 5. BLoC
  sl.registerFactory<ConnectionWithPropertiesBloc>(
    () => ConnectionWithPropertiesBloc(sl<GetConnectionWithProperties>()),
  );
}
