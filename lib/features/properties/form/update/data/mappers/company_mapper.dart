import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_company_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/company_repository.dart';

class CompanyMapper {
  static UpdateCompanyRequest toUpdateRequest(UpdateCompanyParams params) {
    return UpdateCompanyRequest(
      companyName: params.companyName,
      socialReason: params.socialReason,
      companyAddress: params.companyAddress,
      companyParishId: params.companyParishId,
      companyCountry: params.companyCountry,
      companyEmails: params.companyEmails,
      companyPhones: params.companyPhones,
      identificationType: params.identificationType,
    );
  }
}
