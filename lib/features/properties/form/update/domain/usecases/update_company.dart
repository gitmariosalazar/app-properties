import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';

class UpdateCompanyUseCase {
  final CompanyRepository repository;

  UpdateCompanyUseCase(this.repository);

  Future<void> call({
    required String companyRuc,
    required UpdateCompanyParams params,
  }) async {
    return await repository.updateCompany(
      companyRuc: companyRuc,
      params: params,
    );
  }
}
