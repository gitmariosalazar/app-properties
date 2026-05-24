import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/property_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/property_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final OfflineSyncManager offlineSyncManager;
  final NetworkInfo networkInfo;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncManager,
    required this.networkInfo,
  });

  @override
  Future<void> updateProperty({
    required String cadastralKey,
    required UpdatePropertyParams params,
  }) async {
    final request = PropertyMapper.toRequest(params, cadastralKey);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateProperty(
          cadastralKey: cadastralKey,
          request: request,
        );
      } catch (e) {
        await offlineSyncManager.enqueueTask(
          type: 'property',
          entityId: cadastralKey,
          payload: request.toJson(),
        );
      }
    } else {
      await offlineSyncManager.enqueueTask(
        type: 'property',
        entityId: cadastralKey,
        payload: request.toJson(),
      );
    }
  }
}
