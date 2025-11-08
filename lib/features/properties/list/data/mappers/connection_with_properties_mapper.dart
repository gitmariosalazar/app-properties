// lib/features/properties/data/mappers/connection_mapper.dart

import 'package:app_properties/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:app_properties/features/properties/list/domain/entities/connection.dart';
import 'person_mapper.dart';
import 'company_mapper.dart';
import 'property_mapper.dart';

extension ConnectionWithPropertiesMapper
    on dto.ConnectionWithPropertiesResponse {
  ConnectionEntity toEntity() {
    return ConnectionEntity(
      connectionId: connectionId,
      clientId: clientId,
      connectionRateId: connectionRateId ?? 0,
      connectionRateName: connectionRateName,
      connectionMeterNumber: connectionMeterNumber,
      connectionSector: connectionSector ?? 0,
      connectionAccount: connectionAccount ?? 0,
      connectionCadastralKey: connectionCadastralKey,
      connectionContractNumber: connectionContractNumber,
      connectionSewerage: connectionSewerage,
      connectionStatus: connectionStatus,
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
      properties: properties?.map((e) => e.toEntity()).toList(),
    );
  }
}
