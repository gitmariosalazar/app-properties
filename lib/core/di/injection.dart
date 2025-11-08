import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === AUTH ===
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/presentation/bloc/auth_bloc.dart';

// === SCAN ===
import 'package:app_properties/features/scan/data/datasources/scan_datasource.dart';
import 'package:app_properties/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:app_properties/features/scan/domain/repositories/scan_repository.dart';
import 'package:app_properties/features/scan/domain/usecases/scan_usecase.dart';
import 'package:app_properties/features/scan/presentation/bloc/scan_bloc.dart';

// === FORM ===
import 'package:app_properties/features/form/presentation/blocs/readings/form_bloc.dart';

// === MANUALLY ===
import 'package:app_properties/features/manually/data/datasources/manually_datasource.dart';
import 'package:app_properties/features/manually/data/repositories/manually_repository_impl.dart';
import 'package:app_properties/features/manually/domain/repositories/manually_repository.dart';
import 'package:app_properties/features/manually/domain/usecases/manually_usecase.dart';
import 'package:app_properties/features/manually/presentation/bloc/manually_bloc.dart';

// === OBSERVATIONS ===
import 'package:app_properties/features/observations/data/datasources/observations_datasource.dart';
import 'package:app_properties/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:app_properties/features/observations/domain/repositories/observation_repository.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';

// === PHOTO READING ===
import 'package:app_properties/features/form/data/datasources/photo_reading_datasource.dart';
import 'package:app_properties/features/form/data/repositories/photo_reading_repository_impl.dart';
import 'package:app_properties/features/form/domain/repositories/photo_reading_repository.dart';
import 'package:app_properties/features/form/domain/usecases/create_photo_reading_use_case.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';

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
  sl.registerLazySingleton<ScanDataSource>(() => ScanDataSourceImpl());
  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ScanUseCase>(() => ScanUseCase(sl()));
  sl.registerFactory(() => ScanBloc(scanUseCase: sl()));

  // ====================
  // FORM
  // ====================
  sl.registerFactory(() => FormBloc());

  // ====================
  // MANUALLY
  // ====================
  sl.registerLazySingleton<ManuallyDataSource>(() => ManuallyDataSourceImpl());
  sl.registerLazySingleton<ManuallyRepository>(
    () => ManuallyRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ManuallyUseCase>(() => ManuallyUseCase(sl()));
  sl.registerFactory(() => ManuallyBloc(sl()));
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
  sl.registerLazySingleton<PhotoReadingDataSource>(
    () => PhotoReadingDataSource(),
  );
  sl.registerLazySingleton<PhotoReadingRepository>(
    () => PhotoReadingRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<CreatePhotoReadingUseCase>(
    () => CreatePhotoReadingUseCase(sl()),
  );
  sl.registerFactory(() => PhotoReadingBloc(sl()));

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
