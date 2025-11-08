// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_company_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCompanyRequest _$UpdateCompanyRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCompanyRequest(
  companyName: json['companyName'] as String,
  socialReason: json['socialReason'] as String,
  companyAddress: json['companyAddress'] as String,
  companyParishId: json['companyParishId'] as String,
  companyCountry: json['companyCountry'] as String,
  companyEmails: (json['companyEmails'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  companyPhones: (json['companyPhones'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  identificationType: json['identificationType'] as String,
);

Map<String, dynamic> _$UpdateCompanyRequestToJson(
  UpdateCompanyRequest instance,
) => <String, dynamic>{
  'companyName': instance.companyName,
  'socialReason': instance.socialReason,
  'companyAddress': instance.companyAddress,
  'companyParishId': instance.companyParishId,
  'companyCountry': instance.companyCountry,
  'companyEmails': instance.companyEmails,
  'companyPhones': instance.companyPhones,
  'identificationType': instance.identificationType,
};
