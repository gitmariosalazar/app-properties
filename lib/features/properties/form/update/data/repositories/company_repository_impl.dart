import 'package:app_properties/features/properties/form/update/data/datasources/company_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/company_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyParams params,
  }) async {
    final request = CompanyMapper.toUpdateRequest(params);
    await remoteDataSource.updateCompany(
      companyRuc: companyRuc,
      request: request,
    );
  }
}
