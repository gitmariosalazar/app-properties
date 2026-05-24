import 'package:app_properties/features/properties/search/domain/entities/company.dart';
import 'package:app_properties/features/properties/search/domain/entities/person.dart';
import 'package:app_properties/features/properties/search/domain/entities/property.dart';
import 'package:equatable/equatable.dart';

class ConnectionEntity extends Equatable {
  final String connectionId;
  final String clientId;
  final int connectionRateId;
  final String connectionRateName;
  final String? connectionMeterNumber;
  final String? connectionMeterNumberPreview;
  final String? connectionMeterNumberCurrent;
  final int connectionSector;
  final int connectionAccount;
  final String connectionCadastralKey;
  final String? connectionContractNumber;
  final bool? connectionSewerage;
  final bool? connectionStatus;
  final int? connectionStateId;
  final bool? connectionIsReadable;
  final String connectionAddress;
  final String? connectionInstallationDate;
  final int? connectionPeopleNumber;
  final int? connectionZone;
  final String? connectionCoordinates;
  final String? connectionReference;
  final Map<String, dynamic>? connectionMetadata;
  final double? connectionAltitude;
  final double? connectionPrecision;
  final DateTime? connectionGeolocationDate;
  final String? connectionGeometricZone;
  final String? propertyCadastralKey;
  final int? zoneId;
  final String? zoneCode;
  final String? zoneName;
  final PersonEntity? person;
  final CompanyEntity? company;
  final PropertyEntity? property;

  const ConnectionEntity({
    required this.connectionId,
    required this.clientId,
    required this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    this.connectionMeterNumberPreview,
    this.connectionMeterNumberCurrent,
    required this.connectionSector,
    required this.connectionAccount,
    required this.connectionCadastralKey,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    this.connectionStateId,
    this.connectionIsReadable,
    required this.connectionAddress,
    required this.connectionInstallationDate,
    this.connectionPeopleNumber,
    this.connectionZone,
    this.connectionCoordinates,
    this.connectionReference,
    this.connectionMetadata,
    this.connectionAltitude,
    this.connectionPrecision,
    this.connectionGeolocationDate,
    this.connectionGeometricZone,
    this.propertyCadastralKey,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.person,
    this.company,
    this.property,
  });

  @override
  List<Object?> get props => [
    connectionId,
    clientId,
    connectionRateId,
    connectionRateName,
    connectionMeterNumber,
    connectionMeterNumberPreview,
    connectionMeterNumberCurrent,
    connectionSector,
    connectionAccount,
    connectionCadastralKey,
    connectionContractNumber,
    connectionGeometricZone,
    connectionSewerage,
    connectionStatus,
    connectionStateId,
    connectionIsReadable,
    connectionAddress,
    connectionInstallationDate,
    connectionPeopleNumber,
    connectionZone,
    connectionCoordinates,
    connectionReference,
    connectionMetadata,
    connectionAltitude,
    connectionPrecision,
    connectionGeolocationDate,
    connectionGeometricZone,
    propertyCadastralKey,
    zoneId,
    zoneCode,
    zoneName,
    person,
    company,
    property,
  ];
}

class ConnectionWithPropertiesEntity extends Equatable {
  final String connectionId;
  final String clientId;
  final int connectionRateId;
  final String connectionRateName;
  final String? connectionMeterNumber;
  final String? connectionMeterNumberPreview;
  final String? connectionMeterNumberCurrent;
  final int connectionSector;
  final int connectionAccount;
  final String connectionCadastralKey;
  final String? connectionContractNumber;
  final bool? connectionSewerage;
  final bool? connectionStatus;
  final int? connectionStateId;
  final bool? connectionIsReadable;
  final String connectionAddress;
  final String? connectionInstallationDate;
  final int? connectionPeopleNumber;
  final int? connectionZone;
  final String? connectionCoordinates;
  final String? connectionReference;
  final Map<String, dynamic>? connectionMetadata;
  final double? connectionAltitude;
  final double? connectionPrecision;
  final DateTime? connectionGeolocationDate;
  final String? connectionGeometricZone;
  final String? propertyCadastralKey;
  final int? zoneId;
  final String? zoneCode;
  final String? zoneName;
  final PersonEntity? person;
  final CompanyEntity? company;
  final List<PropertyEntity>? properties;

  const ConnectionWithPropertiesEntity({
    required this.connectionId,
    required this.clientId,
    required this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    this.connectionMeterNumberPreview,
    this.connectionMeterNumberCurrent,
    required this.connectionSector,
    required this.connectionAccount,
    required this.connectionCadastralKey,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    this.connectionStateId,
    this.connectionIsReadable,
    required this.connectionAddress,
    required this.connectionInstallationDate,
    this.connectionPeopleNumber,
    this.connectionZone,
    this.connectionCoordinates,
    this.connectionReference,
    this.connectionMetadata,
    this.connectionAltitude,
    this.connectionPrecision,
    this.connectionGeolocationDate,
    this.connectionGeometricZone,
    this.propertyCadastralKey,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.person,
    this.company,
    this.properties,
  });

  @override
  List<Object?> get props => [
    connectionId,
    clientId,
    connectionRateId,
    connectionRateName,
    connectionMeterNumber,
    connectionMeterNumberPreview,
    connectionMeterNumberCurrent,
    connectionSector,
    connectionAccount,
    connectionCadastralKey,
    connectionContractNumber,
    connectionGeometricZone,
    connectionSewerage,
    connectionStatus,
    connectionStateId,
    connectionIsReadable,
    connectionAddress,
    connectionInstallationDate,
    connectionPeopleNumber,
    connectionZone,
    connectionCoordinates,
    connectionReference,
    connectionMetadata,
    connectionAltitude,
    connectionPrecision,
    connectionGeolocationDate,
    connectionGeometricZone,
    propertyCadastralKey,
    zoneId,
    zoneCode,
    zoneName,
    person,
    company,
    properties,
  ];
}
