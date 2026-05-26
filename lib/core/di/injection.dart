import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/search/data/datasources/local_connection_datasource.dart';

// === UPDATE FEATURE ===
import 'package:app_properties/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/observation_connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/property_remote_data_source.dart';

import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart' as update_domain_repo;
import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';

import 'package:app_properties/features/properties/form/update/data/repositories/company_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/connection_repository_impl.dart' as update_data_repo;
import 'package:app_properties/features/properties/form/update/data/repositories/customer_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/observation_connection_repository_impl.dart';
import 'package:app_properties/features/properties/form/update/data/repositories/property_repository_impl.dart';

import 'package:app_properties/features/properties/form/update/domain/usecases/update_company.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_customer.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/update_property.dart';
import 'package:app_properties/features/properties/form/update/domain/usecases/add_observation_connection.dart';

import 'package:app_properties/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_properties/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_properties/features/auth/domain/usecases/verify_user_usecase.dart';
import 'package:app_properties/features/auth/presentation/cubit/login_cubit.dart';
import 'package:app_properties/features/properties/form/add-img/data/datasources/property_image_remote_data_source.dart';
import 'package:app_properties/features/properties/form/add-img/data/repositories/property_image_repository_impl.dart';
import 'package:app_properties/features/properties/form/add-img/domain/repositories/property_image_repository.dart';
import 'package:app_properties/features/properties/form/add-img/domain/usecases/add_property_images.dart';
import 'package:app_properties/features/properties/form/add-img/presentation/blocs/add_property_image_bloc.dart';
import 'package:app_properties/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:app_properties/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:app_properties/features/theme/domain/repositories/theme_repository.dart';
import 'package:app_properties/features/theme/domain/usecases/get_theme_mode.dart';
import 'package:app_properties/features/theme/domain/usecases/save_theme_mode.dart';
import 'package:app_properties/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:app_properties/features/properties/form/documents/data/datasources/document_remote_datasource.dart';
import 'package:app_properties/features/properties/form/documents/data/repositories/document_repository_impl.dart';
import 'package:app_properties/features/properties/form/documents/domain/repositories/document_repository.dart';
import 'package:app_properties/features/properties/form/documents/domain/usecases/upload_document_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === AUTH ===
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:app_properties/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_properties/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_properties/features/auth/domain/usecases/login_usecase.dart';

// === OBSERVATIONS ===
import 'package:app_properties/features/observations/data/datasources/observations_datasource.dart';
import 'package:app_properties/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:app_properties/features/observations/domain/repositories/observation_repository.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:app_properties/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:app_properties/features/observations/presentation/bloc/observation_bloc.dart';

// === CONNECTION WITH PROPERTIES ===
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:app_properties/features/properties/search/data/datasources/remote_connection_datasource.dart';
import 'package:app_properties/features/properties/search/data/repositories/connection_with_properties_repository_impl.dart';
import 'package:app_properties/features/properties/search/data/repositories/connection_repository_impl.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';
import 'package:app_properties/features/properties/search/domain/usecases/get_connection_with_properties.dart';
import 'package:app_properties/features/properties/search/domain/usecases/find_property_with_client.dart';
import 'package:app_properties/features/properties/search/presentation/scan/blocs/connection_with_properties_bloc.dart';
import 'package:app_properties/features/properties/search/presentation/manually/blocs/index.dart';
import 'package:app_properties/features/properties/search/presentation/info/cubit/search_connection_cubit.dart';
import 'package:app_properties/features/properties/search/domain/services/document_export_service.dart';
import 'package:app_properties/features/properties/search/data/services/pdf_document_export_service_impl.dart';

// === DASHBOARD ===
import 'package:app_properties/features/properties/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:app_properties/features/properties/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:app_properties/features/properties/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:app_properties/features/properties/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/domain/usecases/watch_dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  // ====================
  // EXTERNAL
  // ====================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // ====================
  // AUTH
  // ====================
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(sl()),
  );
  sl.registerLazySingleton<VerifyUserUseCase>(() => VerifyUserUseCase(sl()));
  sl.registerFactory(
    () => LoginCubit(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      verifyUserUseCase: sl(),
    ),
  );

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
  // CONNECTION WITH PROPERTIES
  // ====================
  sl.registerLazySingleton<RemoteConnectionWithPropertiesDataSource>(
    () => RemoteConnectionWithPropertiesDataSourceImpl(
      sl<http.Client>(),
      sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<ConnectionWithPropertiesRepository>(
    () => ConnectionWithPropertiesRepositoryImpl(
      remoteConnectionWithPropertiesDataSource: sl(),
      localConnectionDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<GetConnectionWithProperties>(
    () => GetConnectionWithProperties(sl<ConnectionWithPropertiesRepository>()),
  );
  sl.registerFactory<ConnectionWithPropertiesBloc>(
    () => ConnectionWithPropertiesBloc(sl<GetConnectionWithProperties>()),
  );
  sl.registerLazySingleton<RemoteConnectionDataSource>(
    () => RemoteConnectionDataSourceImpl(sl<http.Client>(), sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<ConnectionRepository>(
    () => ConnectionRepositoryImpl(
      remoteConnectionDataSource: sl(),
      localConnectionDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<GetConnection>(
    () => GetConnection(sl<ConnectionRepository>()),
  );
  sl.registerLazySingleton<FindPropertyWithClient>(
    () => FindPropertyWithClient(sl<ConnectionRepository>()),
  );
  sl.registerFactory<SearchConnectionCubit>(
    () => SearchConnectionCubit(sl<GetConnection>()),
  );
  sl.registerLazySingleton<DocumentExportService>(
    () => PdfDocumentExportServiceImpl(),
  );
  // ====================
  // IMÁGENES DE PROPIEDAD
  // ====================
  sl.registerLazySingleton<PropertyImageRemoteDataSource>(
    () => PropertyImageRemoteDataSourceImpl(sl<http.Client>()),
  );
  sl.registerLazySingleton<PropertyImageRepository>(
    () => PropertyImageRepositoryImpl(sl<PropertyImageRemoteDataSource>()),
  );
  sl.registerLazySingleton<AddPropertyImagesUseCase>(
    () => AddPropertyImagesUseCase(sl<PropertyImageRepository>()),
  );
  sl.registerFactory<AddPropertyImageBloc>(
    () => AddPropertyImageBloc(sl<AddPropertyImagesUseCase>()),
  );

  // ====================
  // CARGA DE DOCUMENTOS
  // ====================
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(sl<http.Client>(), sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(sl<DocumentRemoteDataSource>()),
  );
  sl.registerLazySingleton<UploadDocumentUseCase>(
    () => UploadDocumentUseCase(sl<DocumentRepository>()),
  );

  // ==========================
  // DASHBOARD
  // ==========================
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      client: sl<http.Client>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    ),
  );
  // LazySingleton para que el polling timer persista entre navegaciones.
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GetDashboardStats>(() => GetDashboardStats(sl()));
  sl.registerLazySingleton<WatchDashboardStats>(
    () => WatchDashboardStats(sl()),
  );
  sl.registerFactory(() => DashboardCubit(sl(), sl()));

  // ==========================
  // THEME FEATURE
  // ==========================
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<GetThemeMode>(() => GetThemeMode(sl()));
  sl.registerLazySingleton<SaveThemeMode>(() => SaveThemeMode(sl()));
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getThemeMode: sl(), saveThemeMode: sl()),
  );

  // ==========================
  // OFFLINE & CORE NETWORK
  // ==========================
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => InternetConnectionChecker.instance);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl(), connectionChecker: sl()),
  );
  sl.registerLazySingleton<LocalConnectionDataSource>(
    () => LocalConnectionDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<OfflineSyncManager>(
    () => OfflineSyncManager(sharedPreferences: sl(), networkInfo: sl()),
  );

  // ==========================
  // UPDATE FEATURE (DATA & DOMAIN)
  // ==========================
  sl.registerLazySingleton(() => ConnectionRemoteDataSource(client: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => CompanyRemoteDataSource(client: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => CustomerRemoteDataSource(client: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => PropertyRemoteDataSource(client: sl(), authLocalDataSource: sl()));
  sl.registerLazySingleton(() => ObservationConnectionRemoteDataSource(client: sl(), authLocalDataSource: sl()));

  sl.registerLazySingleton<update_domain_repo.ConnectionRepository>(
    () => update_data_repo.ConnectionRepositoryImpl(
      remoteDataSource: sl(),
      offlineSyncManager: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(
      remoteDataSource: sl(),
      offlineSyncManager: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: sl(),
      offlineSyncManager: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(
      remoteDataSource: sl(),
      offlineSyncManager: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<ObservationConnectionRepository>(
    () => ObservationConnectionRepositoryImpl(
      remoteDataSource: sl(),
      offlineSyncManager: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => UpdateConnectionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCompanyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePropertyUseCase(sl()));
  sl.registerLazySingleton(() => AddObservationConnectionUseCase(sl()));
}
