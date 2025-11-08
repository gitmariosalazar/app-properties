abstract class CompanyRepository {
  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyParams params,
  });
}

class UpdateCompanyParams {
  final String companyName;
  final String socialReason;
  final String companyAddress;
  final String companyParishId;
  final String companyCountry;
  final List<String> companyEmails;
  final List<String> companyPhones;
  final String identificationType;

  UpdateCompanyParams({
    required this.companyName,
    required this.socialReason,
    required this.companyAddress,
    required this.companyParishId,
    required this.companyCountry,
    required this.companyEmails,
    required this.companyPhones,
    required this.identificationType,
  });
}
