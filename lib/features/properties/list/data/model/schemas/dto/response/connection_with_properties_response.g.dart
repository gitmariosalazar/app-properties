// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_with_properties_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phone _$PhoneFromJson(Map<String, dynamic> json) => Phone(
  telefonoid: _toIntOrNull(json['telefonoid']),
  numero: json['numero'] as String,
);

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
  'telefonoid': instance.telefonoid,
  'numero': instance.numero,
};

Email _$EmailFromJson(Map<String, dynamic> json) => Email(
  correoid: _toIntOrNull(json['correoid']),
  email: json['email'] as String,
);

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
  'correoid': instance.correoid,
  'email': instance.email,
};

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
  personId: _toStringNonNull(json['personId']),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  address: json['address'] as String?,
  country: json['country'] as String?,
  genderId: _toIntOrNull(json['genderId']),
  parishId: _toStringOrNull(json['parishId']),
  birthDate: json['birthDate'] as String?,
  isDeceased: json['isDeceased'] as bool?,
  professionId: _toIntOrNull(json['professionId']),
  civilStatus: _toIntOrNull(json['civilStatus']),
  emails: (json['emails'] as List<dynamic>)
      .map((e) => e == null ? null : Email.fromJson(e as Map<String, dynamic>))
      .toList(),
  phones: (json['phones'] as List<dynamic>)
      .map((e) => e == null ? null : Phone.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
  'personId': instance.personId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'address': instance.address,
  'country': instance.country,
  'genderId': instance.genderId,
  'parishId': instance.parishId,
  'birthDate': instance.birthDate,
  'isDeceased': instance.isDeceased,
  'professionId': instance.professionId,
  'civilStatus': instance.civilStatus,
  'emails': instance.emails.map((e) => e?.toJson()).toList(),
  'phones': instance.phones.map((e) => e?.toJson()).toList(),
};

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  ruc: json['ruc'] as String,
  address: json['address'] as String?,
  country: json['country'] as String?,
  clientId: json['clientId'] as String,
  parishId: _toStringOrNull(json['parishId']),
  companyId: _toIntOrNull(json['companyId']),
  businessName: json['businessName'] as String?,
  commercialName: json['commercialName'] as String?,
  emails: (json['emails'] as List<dynamic>)
      .map((e) => e == null ? null : Email.fromJson(e as Map<String, dynamic>))
      .toList(),
  phones: (json['phones'] as List<dynamic>)
      .map((e) => e == null ? null : Phone.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'ruc': instance.ruc,
  'address': instance.address,
  'country': instance.country,
  'clientId': instance.clientId,
  'parishId': instance.parishId,
  'companyId': instance.companyId,
  'businessName': instance.businessName,
  'commercialName': instance.commercialName,
  'emails': instance.emails.map((e) => e?.toJson()).toList(),
  'phones': instance.phones.map((e) => e?.toJson()).toList(),
};

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  propertyId: _toStringNonNull(json['propertyId']),
  propertySector: _toStringOrNull(json['propertySector']),
  propertyTypeId: _toIntOrNull(json['propertyTypeId']),
  propertyTypeName: _toStringOrNull(json['propertyTypeName']),
  propertyAddress: _toStringOrNull(json['propertyAddress']),
  propertyAlleyway: _toStringOrNull(json['propertyAlleyway']),
  propertyAltitude: _toDoubleOrNull(json['propertyAltitude']),
  propertyPrecision: _toDoubleOrNull(json['propertyPrecision']),
  propertyReference: _toStringOrNull(json['propertyReference']),
  propertyCoordinates: _toStringOrNull(json['propertyCoordinates']),
  propertyCadastralKey: _toStringOrNull(json['propertyCadastralKey']),
  propertyGeometricZone: _toStringOrNull(json['propertyGeometricZone']),
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  'propertyId': instance.propertyId,
  'propertySector': instance.propertySector,
  'propertyTypeId': instance.propertyTypeId,
  'propertyTypeName': instance.propertyTypeName,
  'propertyAddress': instance.propertyAddress,
  'propertyAlleyway': instance.propertyAlleyway,
  'propertyAltitude': instance.propertyAltitude,
  'propertyPrecision': instance.propertyPrecision,
  'propertyReference': instance.propertyReference,
  'propertyCoordinates': instance.propertyCoordinates,
  'propertyCadastralKey': instance.propertyCadastralKey,
  'propertyGeometricZone': instance.propertyGeometricZone,
};

ConnectionWithPropertiesResponse _$ConnectionWithPropertiesResponseFromJson(
  Map<String, dynamic> json,
) => ConnectionWithPropertiesResponse(
  connectionId: _toStringNonNull(json['connectionId']),
  clientId: _toStringOrNull(json['clientId']),
  connectionRateId: _toIntOrNull(json['connectionRateId']),
  connectionRateName: _toStringOrNull(json['connectionRateName']),
  connectionMeterNumber: _toStringOrNull(json['connectionMeterNumber']),
  connectionSector: _toIntOrNull(json['connectionSector']),
  connectionAccount: _toIntOrNull(json['connectionAccount']),
  connectionCadastralKey: _toStringOrNull(json['connectionCadastralKey']),
  connectionContractNumber: _toStringOrNull(json['connectionContractNumber']),
  connectionSewerage: json['connectionSewerage'] as bool?,
  connectionStatus: json['connectionStatus'] as bool?,
  connectionAddress: _toStringOrNull(json['connectionAddress']),
  connectionInstallationDate: _toStringOrNull(
    json['connectionInstallationDate'],
  ),
  connectionPeopleNumber: _toIntOrNull(json['connectionPeopleNumber']),
  connectionZone: _toIntOrNull(json['connectionZone']),
  connectionCoordinates: _toStringOrNull(json['connectionCoordinates']),
  connectionReference: _toStringOrNull(json['connectionReference']),
  connectionMetadata: json['connectionMetadata'] as Map<String, dynamic>?,
  connectionAltitude: _toDoubleOrNull(json['connectionAltitude']),
  connectionPrecision: _toDoubleOrNull(json['connectionPrecision']),
  connectionGeolocationDate: _toDateTimeOrNull(
    json['connectionGeolocationDate'],
  ),
  connectionGeometricZone: _toStringOrNull(json['connectionGeometricZone']),
  propertyCadastralKey: _toStringOrNull(json['propertyCadastralKey']),
  zoneId: _toIntOrNull(json['zoneId']),
  zoneCode: _toStringOrNull(json['zoneCode']),
  zoneName: _toStringOrNull(json['zoneName']),
  person: json['person'] == null
      ? null
      : Person.fromJson(json['person'] as Map<String, dynamic>),
  company: json['company'] == null
      ? null
      : Company.fromJson(json['company'] as Map<String, dynamic>),
  properties: (json['properties'] as List<dynamic>?)
      ?.map((e) => Property.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ConnectionWithPropertiesResponseToJson(
  ConnectionWithPropertiesResponse instance,
) => <String, dynamic>{
  'connectionId': instance.connectionId,
  'clientId': instance.clientId,
  'connectionRateId': instance.connectionRateId,
  'connectionRateName': instance.connectionRateName,
  'connectionMeterNumber': instance.connectionMeterNumber,
  'connectionSector': instance.connectionSector,
  'connectionAccount': instance.connectionAccount,
  'connectionCadastralKey': instance.connectionCadastralKey,
  'connectionContractNumber': instance.connectionContractNumber,
  'connectionSewerage': instance.connectionSewerage,
  'connectionStatus': instance.connectionStatus,
  'connectionAddress': instance.connectionAddress,
  'connectionInstallationDate': instance.connectionInstallationDate,
  'connectionPeopleNumber': instance.connectionPeopleNumber,
  'connectionZone': instance.connectionZone,
  'connectionCoordinates': instance.connectionCoordinates,
  'connectionReference': instance.connectionReference,
  'connectionMetadata': instance.connectionMetadata,
  'connectionAltitude': instance.connectionAltitude,
  'connectionPrecision': instance.connectionPrecision,
  'connectionGeolocationDate': instance.connectionGeolocationDate
      ?.toIso8601String(),
  'connectionGeometricZone': instance.connectionGeometricZone,
  'propertyCadastralKey': instance.propertyCadastralKey,
  'zoneId': instance.zoneId,
  'zoneCode': instance.zoneCode,
  'zoneName': instance.zoneName,
  'person': instance.person?.toJson(),
  'company': instance.company?.toJson(),
  'properties': instance.properties?.map((e) => e.toJson()).toList(),
};
