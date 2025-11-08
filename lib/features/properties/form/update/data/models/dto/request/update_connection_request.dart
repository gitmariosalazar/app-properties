// lib/features/properties/put/data/models/dto/request/update_connection_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'update_connection_request.g.dart';

@JsonSerializable()
class UpdateConnectionRequest {
  final String connectionId;
  final String clientId;
  final int connectionRateId;
  final String connectionRateName;
  final String connectionMeterNumber;
  final String connectionContractNumber;
  final bool connectionSewerage;
  final bool connectionStatus;
  final String connectionAddress;
  final String connectionInstallationDate;
  final int connectionPeopleNumber;
  final int connectionZone;
  final double longitude;
  final double latitude;
  final String connectionReference;
  final Map<String, dynamic> connectionMetaData;
  final double connectionAltitude;
  final double connectionPrecision;
  final String connectionGeolocationDate;
  final String connectionGeometricZone;
  final String propertyCadastralKey;

  UpdateConnectionRequest({
    required this.connectionId,
    required this.clientId,
    required this.connectionRateId,
    required this.connectionRateName,
    required this.connectionMeterNumber,
    required this.connectionContractNumber,
    required this.connectionSewerage,
    required this.connectionStatus,
    required this.connectionAddress,
    required this.connectionInstallationDate,
    required this.connectionPeopleNumber,
    required this.connectionZone,
    required this.longitude,
    required this.latitude,
    required this.connectionReference,
    this.connectionMetaData = const {},
    this.connectionAltitude = 0.0,
    this.connectionPrecision = 0.0,
    this.connectionGeolocationDate = '',
    this.connectionGeometricZone = '',
    required this.propertyCadastralKey,
  });

  factory UpdateConnectionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateConnectionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateConnectionRequestToJson(this);
}
