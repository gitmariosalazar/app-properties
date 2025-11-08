import 'package:json_annotation/json_annotation.dart';

part 'update_company_request.g.dart';

@JsonSerializable()
class UpdateCompanyRequest {
  final String companyName;
  final String socialReason;
  final String companyAddress;
  final String companyParishId;
  final String companyCountry;
  final List<String> companyEmails;
  final List<String> companyPhones;
  final String identificationType;

  UpdateCompanyRequest({
    required this.companyName,
    required this.socialReason,
    required this.companyAddress,
    required this.companyParishId,
    required this.companyCountry,
    required this.companyEmails,
    required this.companyPhones,
    required this.identificationType,
  });

  factory UpdateCompanyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCompanyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCompanyRequestToJson(this);
}
