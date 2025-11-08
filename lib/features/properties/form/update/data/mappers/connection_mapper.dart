// lib/features/properties/put/data/mappers/connection_mapper.dart
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_connection_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';

class ConnectionMapper {
  static UpdateConnectionRequest toRequest(
    UpdateConnectionParams params,
    String connectionId,
  ) {
    return UpdateConnectionRequest(
      connectionId: connectionId,
      clientId: params.clientId,
      connectionRateId: params.connectionRateId,
      connectionRateName: params.connectionRateName,
      connectionMeterNumber: params.connectionMeterNumber,
      connectionContractNumber: params.connectionContractNumber,
      connectionSewerage: params.connectionSewerage,
      connectionStatus: params.connectionStatus,
      connectionAddress: params.connectionAddress,
      connectionInstallationDate: params.connectionInstallationDate,
      connectionPeopleNumber: params.connectionPeopleNumber,
      connectionZone: params.connectionZone,
      longitude: params.longitude,
      latitude: params.latitude,
      connectionReference: params.connectionReference,
      connectionMetaData: params.connectionMetaData,
      connectionAltitude: params.connectionAltitude,
      connectionPrecision: params.connectionPrecision,
      connectionGeolocationDate: params.connectionGeolocationDate,
      connectionGeometricZone: params.connectionGeometricZone,
      propertyCadastralKey: params.propertyCadastralKey,
    );
  }
}
