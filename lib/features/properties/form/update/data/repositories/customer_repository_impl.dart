import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/customer_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final OfflineSyncManager offlineSyncManager;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncManager,
    required this.networkInfo,
  });

  @override
  Future<void> updateCustomer({
    required String customerId,
    required UpdateCustomerParams params,
  }) async {
    final request = CustomerMapper.toUpdateRequest(params);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateCustomer(
          customerId: customerId,
          request: request,
        );
      } catch (e) {
        await offlineSyncManager.enqueueTask(
          type: 'customer',
          entityId: customerId,
          payload: request.toJson(),
        );
      }
    } else {
      await offlineSyncManager.enqueueTask(
        type: 'customer',
        entityId: customerId,
        payload: request.toJson(),
      );
    }
  }
}
