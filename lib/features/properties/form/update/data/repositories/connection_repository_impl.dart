import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/connection_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionRemoteDataSource remoteDataSource;
  final OfflineSyncManager offlineSyncManager;
  final NetworkInfo networkInfo;

  ConnectionRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncManager,
    required this.networkInfo,
  });

  @override
  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionParams params,
  }) async {
    final request = ConnectionMapper.toRequest(params, connectionId);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateConnection(
          connectionId: connectionId,
          request: request,
        );
      } catch (e) {
        // En caso de fallo temporal de red/servidor, encolamos localmente
        await offlineSyncManager.enqueueTask(
          type: 'connection',
          entityId: connectionId,
          payload: request.toJson(),
        );
      }
    } else {
      // Encolado offline
      await offlineSyncManager.enqueueTask(
        type: 'connection',
        entityId: connectionId,
        payload: request.toJson(),
      );
    }
  }
}
