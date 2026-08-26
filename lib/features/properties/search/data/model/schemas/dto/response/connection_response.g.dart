// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phone _$PhoneFromJson(Map<String, dynamic> json) => Phone(
  telefonoid: _toIntOrNull(json['telefonoid']),
  numero: json['numero'] as String?,
);

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
  'telefonoid': instance.telefonoid,
  'numero': instance.numero,
};

Email _$EmailFromJson(Map<String, dynamic> json) => Email(
  correoid: _toIntOrNull(json['correoid']),
  email: json['email'] as String?,
);

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
  'correoid': instance.correoid,
  'email': instance.email,
};

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
  personId: _toStringNonNull(json['personId']),
  firstName: _toStringOrNull(json['firstName']),
  lastName: _toStringOrNull(json['lastName']),
  address: _toStringOrNull(json['address']),
  country: _toStringOrNull(json['country']),
  genderId: _toIntOrNull(json['genderId']),
  parishId: _toStringOrNull(json['parishId']),
  birthDate: _toStringOrNull(json['birthDate']),
  isDeceased: _toBoolOrNull(json['isDeceased']),
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
  ruc: _toStringNonNull(json['ruc']),
  address: _toStringOrNull(json['address']),
  country: _toStringOrNull(json['country']),
  clientId: _toStringNonNull(json['clientId']),
  parishId: _toStringOrNull(json['parishId']),
  companyId: _toIntOrNull(json['companyId']),
  businessName: _toStringOrNull(json['businessName']),
  commercialName: _toStringOrNull(json['commercialName']),
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
  propertySector: _toStringNonNull(json['propertySector']),
  propertyTypeId: _toIntOrNull(json['propertyTypeId']),
  propertyTypeName: _toStringNonNull(json['propertyTypeName']),
  propertyAddress: _toStringNonNull(json['propertyAddress']),
  propertyAlleyway: _toStringNonNull(json['propertyAlleyway']),
  propertyAltitude: _toDoubleOrNull(json['propertyAltitude']),
  propertyPrecision: _toDoubleOrNull(json['propertyPrecision']),
  propertyReference: _toStringOrNull(json['propertyReference']),
  propertyCoordinates: _toStringOrNull(json['propertyCoordinates']),
  propertyCadastralKey: _toStringNonNull(json['propertyCadastralKey']),
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

LastReading _$LastReadingFromJson(Map<String, dynamic> json) => LastReading(
  cadastralKey: json['cadastralKey'] as String?,
  readingDate: _toDateTimeOrNull(json['readingDate']),
  readingTime: _toStringOrNull(json['readingTime']),
  readingMonth: _toStringOrNull(json['readingMonth']),
  readingValueCurrent: _toDoubleOrNull(json['readingValueCurrent']),
  readingValuePreview: _toDoubleOrNull(json['readingValuePreview']),
  novelty: json['novelty'] as String?,
);

Map<String, dynamic> _$LastReadingToJson(LastReading instance) =>
    <String, dynamic>{
      'cadastralKey': instance.cadastralKey,
      'readingDate': instance.readingDate?.toIso8601String(),
      'readingTime': instance.readingTime,
      'readingMonth': instance.readingMonth,
      'readingValueCurrent': instance.readingValueCurrent,
      'readingValuePreview': instance.readingValuePreview,
      'novelty': instance.novelty,
    };

ConnectionResponse _$ConnectionResponseFromJson(Map<String, dynamic> json) =>
    ConnectionResponse(
      connectionId: _toStringNonNull(json['connectionId']),
      clientId: _toStringNonNull(json['clientId']),
      connectionRateId: _toIntOrNull(json['connectionRateId']),
      connectionRateName: _toStringNonNull(json['connectionRateName']),
      connectionMeterNumber: _toStringOrNull(json['connectionMeterNumber']),
      connectionMeterNumberPreview: _toStringOrNull(
        json['connectionMeterNumberPreview'],
      ),
      connectionMeterNumberCurrent: _toStringOrNull(
        json['connectionMeterNumberCurrent'],
      ),
      connectionSector: _toIntOrNull(json['connectionSector']),
      connectionAccount: _toIntOrNull(json['connectionAccount']),
      connectionCadastralKey: _toStringNonNull(json['connectionCadastralKey']),
      connectionContractNumber: _toStringOrNull(
        json['connectionContractNumber'],
      ),
      connectionSewerage: _toBoolOrNull(json['connectionSewerage']),
      connectionStatus: _toBoolOrNull(json['connectionStatus']),
      connectionStateId: _toIntOrNull(json['connectionStateId']),
      connectionIsReadable: _toBoolOrNull(json['connectionIsReadable']),
      connectionAddress: _toStringNonNull(json['connectionAddress']),
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
      property: json['property'] == null
          ? null
          : Property.fromJson(json['property'] as Map<String, dynamic>),
      lastReadings: (json['lastReadings'] as List<dynamic>?)
          ?.map((e) => LastReading.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ConnectionResponseToJson(ConnectionResponse instance) =>
    <String, dynamic>{
      'connectionId': instance.connectionId,
      'clientId': instance.clientId,
      'connectionRateId': instance.connectionRateId,
      'connectionRateName': instance.connectionRateName,
      'connectionMeterNumber': instance.connectionMeterNumber,
      'connectionMeterNumberPreview': instance.connectionMeterNumberPreview,
      'connectionMeterNumberCurrent': instance.connectionMeterNumberCurrent,
      'connectionSector': instance.connectionSector,
      'connectionAccount': instance.connectionAccount,
      'connectionCadastralKey': instance.connectionCadastralKey,
      'connectionContractNumber': instance.connectionContractNumber,
      'connectionSewerage': instance.connectionSewerage,
      'connectionStatus': instance.connectionStatus,
      'connectionStateId': instance.connectionStateId,
      'connectionIsReadable': instance.connectionIsReadable,
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
      'property': instance.property?.toJson(),
      'lastReadings': instance.lastReadings?.map((e) => e.toJson()).toList(),
    };
