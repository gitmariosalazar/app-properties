import 'package:app_properties/features/properties/form/update/data/datasources/observation_connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/observation_connection_mapper.dart';

class ObservationConnectionRepositoryImpl
    implements ObservationConnectionRepository {
  final ObservationConnectionRemoteDataSource remoteDataSource;

  ObservationConnectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addObservationConnection({
    required CreateObservationParams params,
  }) async {
    final request =
        ObservationConnectionMapper.toCreateObservationConnectionRequest(
          params,
        );
    await remoteDataSource.addObservationConnection(request: request);
  }
}
