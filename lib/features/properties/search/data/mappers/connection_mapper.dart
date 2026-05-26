// lib/features/properties/data/mappers/connection_mapper.dart

import 'package:app_properties/features/properties/search/data/model/schemas/dto/response/connection_response.dart'
    as dto;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/entities/contact.dart';
import 'package:app_properties/features/properties/search/domain/entities/person.dart';
import 'package:app_properties/features/properties/search/domain/entities/company.dart';
import 'package:app_properties/features/properties/search/domain/entities/property.dart';

extension ConnectionMapper on dto.ConnectionResponse {
  ConnectionEntity toEntity() {
    return ConnectionEntity(
      connectionId: connectionId,
      clientId: clientId,
      connectionRateId: connectionRateId ?? 0,
      connectionRateName: connectionRateName,
      connectionMeterNumber: connectionMeterNumber,
      connectionMeterNumberPreview: connectionMeterNumberPreview,
      connectionMeterNumberCurrent: connectionMeterNumberCurrent,
      connectionSector: connectionSector ?? 0,
      connectionAccount: connectionAccount ?? 0,
      connectionCadastralKey: connectionCadastralKey,
      connectionContractNumber: connectionContractNumber,
      connectionSewerage: connectionSewerage,
      connectionStatus: connectionStatus,
      connectionStateId: connectionStateId,
      connectionIsReadable: connectionIsReadable,
      connectionAddress: connectionAddress,
      connectionInstallationDate: connectionInstallationDate,
      connectionPeopleNumber: connectionPeopleNumber,
      connectionZone: connectionZone,
      connectionCoordinates: connectionCoordinates,
      connectionReference: connectionReference,
      connectionMetadata: connectionMetadata,
      connectionAltitude: connectionAltitude,
      connectionPrecision: connectionPrecision,
      connectionGeolocationDate: connectionGeolocationDate,
      connectionGeometricZone: connectionGeometricZone,
      propertyCadastralKey: propertyCadastralKey,
      zoneId: zoneId,
      zoneCode: zoneCode,
      zoneName: zoneName,
      person: person?.toEntity(),
      company: company?.toEntity(),
      property: property?.toEntity(),
    );
  }
}

extension PhoneDtoMapper2 on dto.Phone {
  PhoneEntity toEntity() {
    return PhoneEntity(telefonoid ?? 0, numero ?? '');
  }
}

extension EmailDtoMapper2 on dto.Email {
  EmailEntity toEntity() {
    return EmailEntity(correoid ?? 0, email ?? '');
  }
}

extension PersonDtoMapper2 on dto.Person {
  PersonEntity toEntity() {
    return PersonEntity(
      personId: personId,
      firstName: firstName,
      lastName: lastName,
      address: address,
      country: country,
      genderId: genderId,
      parishId: parishId,
      birthDate: birthDate,
      isDeceased: isDeceased,
      professionId: professionId ?? 0,
      civilStatus: civilStatus ?? 0,
      emails: emails.map((e) => e?.toEntity()).toList(),
      phones: phones.map((e) => e?.toEntity()).toList(),
    );
  }
}

extension CompanyDtoMapper2 on dto.Company {
  CompanyEntity toEntity() {
    return CompanyEntity(
      ruc: ruc,
      address: address,
      country: country,
      clientId: clientId,
      parishId: parishId,
      companyId: companyId ?? 0,
      businessName: businessName,
      commercialName: commercialName,
      emails: emails.map((e) => e?.toEntity()).toList(),
      phones: phones.map((e) => e?.toEntity()).toList(),
    );
  }
}

extension PropertyDtoMapper2 on dto.Property {
  PropertyEntity toEntity() {
    return PropertyEntity(
      propertyId: propertyId,
      propertySector: propertySector,
      propertyTypeId: propertyTypeId ?? 0,
      propertyTypeName: propertyTypeName,
      propertyAddress: propertyAddress,
      propertyAlleyway: propertyAlleyway,
      propertyAltitude: propertyAltitude,
      propertyPrecision: propertyPrecision,
      propertyReference: propertyReference,
      propertyCoordinates: propertyCoordinates,
      propertyCadastralKey: propertyCadastralKey,
      propertyGeometricZone: propertyGeometricZone,
    );
  }
}
