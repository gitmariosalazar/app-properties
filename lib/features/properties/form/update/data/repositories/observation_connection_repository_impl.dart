import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/observation_connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/observation_connection_repository.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/observation_connection_mapper.dart';

class ObservationConnectionRepositoryImpl
    implements ObservationConnectionRepository {
  final ObservationConnectionRemoteDataSource remoteDataSource;
  final OfflineSyncManager offlineSyncManager;
  final NetworkInfo networkInfo;

  ObservationConnectionRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncManager,
    required this.networkInfo,
  });

  @override
  Future<void> addObservationConnection({
    required CreateObservationParams params,
  }) async {
    final request =
        ObservationConnectionMapper.toCreateObservationConnectionRequest(
          params,
        );
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addObservationConnection(request: request);
      } catch (e) {
        await offlineSyncManager.enqueueTask(
          type: 'observation',
          entityId: request.connectionId,
          payload: request.toJson(),
        );
      }
    } else {
      await offlineSyncManager.enqueueTask(
        type: 'observation',
        entityId: request.connectionId,
        payload: request.toJson(),
      );
    }
  }
}
