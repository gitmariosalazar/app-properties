// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_connection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateConnectionRequest _$UpdateConnectionRequestFromJson(
  Map<String, dynamic> json,
) => UpdateConnectionRequest(
  connectionId: json['connectionId'] as String,
  clientId: json['clientId'] as String,
  connectionRateId: (json['connectionRateId'] as num).toInt(),
  connectionRateName: json['connectionRateName'] as String,
  connectionMeterNumber: json['connectionMeterNumber'] as String,
  connectionContractNumber: json['connectionContractNumber'] as String,
  connectionSewerage: json['connectionSewerage'] as bool,
  connectionStatus: json['connectionStatus'] as bool,
  connectionAddress: json['connectionAddress'] as String,
  connectionInstallationDate: json['connectionInstallationDate'] as String,
  connectionPeopleNumber: (json['connectionPeopleNumber'] as num).toInt(),
  connectionZone: (json['connectionZone'] as num).toInt(),
  longitude: (json['longitude'] as num).toDouble(),
  latitude: (json['latitude'] as num).toDouble(),
  connectionReference: json['connectionReference'] as String,
  connectionMetaData:
      json['connectionMetaData'] as Map<String, dynamic>? ?? const {},
  connectionAltitude: (json['connectionAltitude'] as num?)?.toDouble() ?? 0.0,
  connectionPrecision: (json['connectionPrecision'] as num?)?.toDouble() ?? 0.0,
  connectionGeolocationDate: json['connectionGeolocationDate'] as String? ?? '',
  connectionGeometricZone: json['connectionGeometricZone'] as String? ?? '',
  propertyCadastralKey: json['propertyCadastralKey'] as String,
);

Map<String, dynamic> _$UpdateConnectionRequestToJson(
  UpdateConnectionRequest instance,
) => <String, dynamic>{
  'connectionId': instance.connectionId,
  'clientId': instance.clientId,
  'connectionRateId': instance.connectionRateId,
  'connectionRateName': instance.connectionRateName,
  'connectionMeterNumber': instance.connectionMeterNumber,
  'connectionContractNumber': instance.connectionContractNumber,
  'connectionSewerage': instance.connectionSewerage,
  'connectionStatus': instance.connectionStatus,
  'connectionAddress': instance.connectionAddress,
  'connectionInstallationDate': instance.connectionInstallationDate,
  'connectionPeopleNumber': instance.connectionPeopleNumber,
  'connectionZone': instance.connectionZone,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'connectionReference': instance.connectionReference,
  'connectionMetaData': instance.connectionMetaData,
  'connectionAltitude': instance.connectionAltitude,
  'connectionPrecision': instance.connectionPrecision,
  'connectionGeolocationDate': instance.connectionGeolocationDate,
  'connectionGeometricZone': instance.connectionGeometricZone,
  'propertyCadastralKey': instance.propertyCadastralKey,
};
