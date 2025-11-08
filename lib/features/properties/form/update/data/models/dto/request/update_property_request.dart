// lib/features/properties/put/data/models/dto/request/update_property_request.dart
import 'package:json_annotation/json_annotation.dart';

part 'update_property_request.g.dart';

@JsonSerializable()
class UpdatePropertyRequest {
  final String propertyCadastralKey;
  final String propertyClientId;
  final String propertyAlleyway;
  final String propertySector;
  final String propertyAddress;
  final double propertyLandArea;
  final double propertyConstructionArea;
  final double propertyLandValue;
  final double propertyConstructionValue;
  final double propertyCommercialValue;
  final double longitude;
  final double latitude;
  final String propertyReference;
  final double propertyAltitude;
  final double propertyPrecision;
  final int propertyTypeId;

  UpdatePropertyRequest({
    required this.propertyCadastralKey,
    required this.propertyClientId,
    required this.propertyAlleyway,
    required this.propertySector,
    required this.propertyAddress,
    required this.propertyLandArea,
    required this.propertyConstructionArea,
    required this.propertyLandValue,
    required this.propertyConstructionValue,
    required this.propertyCommercialValue,
    required this.longitude,
    required this.latitude,
    required this.propertyReference,
    required this.propertyAltitude,
    required this.propertyPrecision,
    required this.propertyTypeId,
  });

  factory UpdatePropertyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePropertyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePropertyRequestToJson(this);
}
