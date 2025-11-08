// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCustomerRequest _$UpdateCustomerRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCustomerRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  emails: (json['emails'] as List<dynamic>).map((e) => e as String).toList(),
  phoneNumbers: (json['phoneNumbers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dateOfBirth: json['dateOfBirth'] as String,
  sexId: (json['sexId'] as num).toInt(),
  civilStatus: (json['civilStatus'] as num).toInt(),
  address: json['address'] as String,
  professionId: (json['professionId'] as num).toInt(),
  originCountry: json['originCountry'] as String,
  identificationType: json['identificationType'] as String,
  parishId: json['parishId'] as String,
  deceased: json['deceased'] as bool,
);

Map<String, dynamic> _$UpdateCustomerRequestToJson(
  UpdateCustomerRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'emails': instance.emails,
  'phoneNumbers': instance.phoneNumbers,
  'dateOfBirth': instance.dateOfBirth,
  'sexId': instance.sexId,
  'civilStatus': instance.civilStatus,
  'address': instance.address,
  'professionId': instance.professionId,
  'originCountry': instance.originCountry,
  'identificationType': instance.identificationType,
  'parishId': instance.parishId,
  'deceased': instance.deceased,
};
