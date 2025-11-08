// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_property_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePropertyRequest _$UpdatePropertyRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePropertyRequest(
  propertyCadastralKey: json['propertyCadastralKey'] as String,
  propertyClientId: json['propertyClientId'] as String,
  propertyAlleyway: json['propertyAlleyway'] as String,
  propertySector: json['propertySector'] as String,
  propertyAddress: json['propertyAddress'] as String,
  propertyLandArea: (json['propertyLandArea'] as num).toDouble(),
  propertyConstructionArea: (json['propertyConstructionArea'] as num)
      .toDouble(),
  propertyLandValue: (json['propertyLandValue'] as num).toDouble(),
  propertyConstructionValue: (json['propertyConstructionValue'] as num)
      .toDouble(),
  propertyCommercialValue: (json['propertyCommercialValue'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  latitude: (json['latitude'] as num).toDouble(),
  propertyReference: json['propertyReference'] as String,
  propertyAltitude: (json['propertyAltitude'] as num).toDouble(),
  propertyPrecision: (json['propertyPrecision'] as num).toDouble(),
  propertyTypeId: (json['propertyTypeId'] as num).toInt(),
);

Map<String, dynamic> _$UpdatePropertyRequestToJson(
  UpdatePropertyRequest instance,
) => <String, dynamic>{
  'propertyCadastralKey': instance.propertyCadastralKey,
  'propertyClientId': instance.propertyClientId,
  'propertyAlleyway': instance.propertyAlleyway,
  'propertySector': instance.propertySector,
  'propertyAddress': instance.propertyAddress,
  'propertyLandArea': instance.propertyLandArea,
  'propertyConstructionArea': instance.propertyConstructionArea,
  'propertyLandValue': instance.propertyLandValue,
  'propertyConstructionValue': instance.propertyConstructionValue,
  'propertyCommercialValue': instance.propertyCommercialValue,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'propertyReference': instance.propertyReference,
  'propertyAltitude': instance.propertyAltitude,
  'propertyPrecision': instance.propertyPrecision,
  'propertyTypeId': instance.propertyTypeId,
};
