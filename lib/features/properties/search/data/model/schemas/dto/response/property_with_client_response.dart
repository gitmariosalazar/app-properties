import 'package:app_properties/features/properties/search/data/model/schemas/dto/response/connection_with_properties_response.dart' as c_dto;
import 'package:app_properties/features/properties/search/domain/entities/property_with_client.dart';
import 'package:app_properties/features/properties/search/data/mappers/company_mapper.dart';
import 'package:app_properties/features/properties/search/data/mappers/person_mapper.dart';

class PropertyWithClientResponse {
  final String propertyId;
  final String? propertySector;
  final int? propertyTypeId;
  final String? propertyAddress;
  final String? propertyAlleyway;
  final double? propertyAltitude;
  final String? propertyTypeName;
  final double? propertyPrecision;
  final String? propertyReference;
  final String? propertyCoordinates;
  final String? propertyCadastralKey;
  final String? propertyGeometricZone;
  final c_dto.Company? company;
  final c_dto.Person? person;

  PropertyWithClientResponse({
    required this.propertyId,
    this.propertySector,
    this.propertyTypeId,
    this.propertyAddress,
    this.propertyAlleyway,
    this.propertyAltitude,
    this.propertyTypeName,
    this.propertyPrecision,
    this.propertyReference,
    this.propertyCoordinates,
    this.propertyCadastralKey,
    this.propertyGeometricZone,
    this.company,
    this.person,
  });

  factory PropertyWithClientResponse.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return PropertyWithClientResponse(
      propertyId: json['propertyId']?.toString() ?? '',
      propertySector: json['propertySector']?.toString(),
      propertyTypeId: parseInt(json['propertyTypeId']),
      propertyAddress: json['propertyAddress']?.toString(),
      propertyAlleyway: json['propertyAlleyway']?.toString(),
      propertyAltitude: parseDouble(json['propertyAltitude']),
      propertyTypeName: json['propertyTypeName']?.toString(),
      propertyPrecision: parseDouble(json['propertyPrecision']),
      propertyReference: json['propertyReference']?.toString(),
      propertyCoordinates: json['propertyCoordinates']?.toString(),
      propertyCadastralKey: json['propertyCadastralKey']?.toString(),
      propertyGeometricZone: json['propertyGeometricZone']?.toString(),
      company: json['company'] != null
          ? c_dto.Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      person: json['person'] != null
          ? c_dto.Person.fromJson(json['person'] as Map<String, dynamic>)
          : null,
    );
  }

  PropertyWithClientEntity toEntity() {
    return PropertyWithClientEntity(
      propertyId: propertyId,
      propertySector: propertySector,
      propertyTypeId: propertyTypeId,
      propertyAddress: propertyAddress,
      propertyAlleyway: propertyAlleyway,
      propertyAltitude: propertyAltitude,
      propertyTypeName: propertyTypeName,
      propertyPrecision: propertyPrecision,
      propertyReference: propertyReference,
      propertyCoordinates: propertyCoordinates,
      propertyCadastralKey: propertyCadastralKey,
      propertyGeometricZone: propertyGeometricZone,
      company: company?.toEntity(),
      person: person?.toEntity(),
    );
  }
}
