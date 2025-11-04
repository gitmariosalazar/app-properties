import 'package:app_properties/features/form/data/datasources/photo_reading_datasource.dart';
import 'package:app_properties/features/form/data/repositories/photo_reading_repository_impl.dart';
import 'package:app_properties/features/form/domain/repositories/photo_reading_repository.dart';
import 'package:app_properties/features/form/domain/usecases/create_photo_reading_use_case.dart';
import 'package:app_properties/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';
import 'package:app_properties/features/observations/data/datasources/observations_datasource.dart';
import 'package:app_properties/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:app_properties/features/observations/domain/repositories/observation_repository.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_properties/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_properties/features/scan/data/datasources/scan_datasource.dart';
import 'package:app_properties/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:app_properties/features/scan/domain/repositories/scan_repository.dart';
import 'package:app_properties/features/scan/domain/usecases/scan_usecase.dart';
import 'package:app_properties/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:app_properties/features/form/presentation/blocs/readings/form_bloc.dart';
import 'package:app_properties/features/manually/data/datasources/manually_datasource.dart';
import 'package:app_properties/features/manually/data/repositories/manually_repository_impl.dart';
import 'package:app_properties/features/manually/domain/repositories/manually_repository.dart';
import 'package:app_properties/features/manually/domain/usecases/manually_usecase.dart';
import 'package:app_properties/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Auth Feature
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // Scan Feature
  sl.registerLazySingleton<ScanDataSource>(() => ScanDataSourceImpl());
  sl.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ScanUseCase>(() => ScanUseCase(sl()));
  sl.registerFactory(() => ScanBloc(scanUseCase: sl()));

  // Form Feature
  sl.registerFactory(() => FormBloc());

  // Manually Feature
  sl.registerLazySingleton<ManuallyDataSource>(() => ManuallyDataSourceImpl());
  sl.registerLazySingleton<ManuallyRepository>(
    () => ManuallyRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<ManuallyUseCase>(() => ManuallyUseCase(sl()));
  sl.registerFactory(() => ManuallyBloc(sl()));

  // Observations Feature
  // Observations Feature
  sl.registerLazySingleton<ObservationsDataSource>(
    () => ObservationsDataSourceImpl(),
  );
  sl.registerLazySingleton<ObservationRepository>(
    () => ObservationRepositoryImpl(dataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton<FindAllObservationsUseCase>(
    () => FindAllObservationsUseCase(sl()),
  );

  sl.registerLazySingleton<FindAllObservationsByCadastralKeyUseCase>(
    () => FindAllObservationsByCadastralKeyUseCase(sl()),
  );

  // Bloc
  sl.registerFactory(
    () => ObservationBloc(
      sl<FindAllObservationsUseCase>(),
      sl<FindAllObservationsByCadastralKeyUseCase>(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<PhotoReadingDataSource>(
    () => PhotoReadingDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<PhotoReadingRepository>(
    () => PhotoReadingRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreatePhotoReadingUseCase(sl()));

  // Blocs
  sl.registerFactory(() => PhotoReadingBloc(sl()));
}
