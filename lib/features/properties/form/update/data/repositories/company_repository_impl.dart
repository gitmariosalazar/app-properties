import 'package:app_properties/core/network/network_info.dart';
import 'package:app_properties/core/network/offline_sync_manager.dart';
import 'package:app_properties/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/company_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  final OfflineSyncManager offlineSyncManager;
  final NetworkInfo networkInfo;

  CompanyRepositoryImpl({
    required this.remoteDataSource,
    required this.offlineSyncManager,
    required this.networkInfo,
  });

  @override
  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyParams params,
  }) async {
    final request = CompanyMapper.toUpdateRequest(params);
    
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateCompany(
          companyRuc: companyRuc,
          request: request,
        );
      } catch (e) {
        await offlineSyncManager.enqueueTask(
          type: 'company',
          entityId: companyRuc,
          payload: request.toJson(),
        );
      }
    } else {
      await offlineSyncManager.enqueueTask(
        type: 'company',
        entityId: companyRuc,
        payload: request.toJson(),
      );
    }
  }
}
