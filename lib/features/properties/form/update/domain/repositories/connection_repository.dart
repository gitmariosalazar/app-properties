abstract class ConnectionRepository {
  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionParams params,
  });
}

class UpdateConnectionParams {
  final String clientId;
  final int? connectionRateId;
  final String connectionRateName;
  final String? connectionMeterNumber;
  final String? connectionContractNumber;
  final bool? connectionSewerage;
  final bool? connectionStatus;
  final String connectionAddress;
  final String? connectionInstallationDate;
  final int? connectionPeopleNumber;
  final int? connectionZone;
  final double longitude;
  final double latitude;
  final String? connectionReference;
  final Map<String, dynamic>? connectionMetaData;
  final double? connectionAltitude;
  final double? connectionPrecision;
  final String? connectionGeolocationDate;
  final String? connectionGeometricZone;
  final String? propertyCadastralKey;
  final int zoneId;

  UpdateConnectionParams({
    required this.clientId,
    this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    required this.connectionAddress,
    this.connectionInstallationDate,
    this.connectionPeopleNumber,
    this.connectionZone,
    required this.longitude,
    required this.latitude,
    this.connectionReference,
    this.connectionMetaData,
    this.connectionAltitude,
    this.connectionPrecision,
    this.connectionGeolocationDate,
    this.connectionGeometricZone,
    this.propertyCadastralKey,
    this.zoneId = 0,
  });
}
