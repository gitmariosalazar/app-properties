import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/search/domain/entities/company.dart';
import 'package:app_properties/features/properties/search/domain/entities/person.dart';

class PropertyWithClientEntity extends Equatable {
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
  final CompanyEntity? company;
  final PersonEntity? person;

  const PropertyWithClientEntity({
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

  @override
  List<Object?> get props => [
        propertyId,
        propertySector,
        propertyTypeId,
        propertyAddress,
        propertyAlleyway,
        propertyAltitude,
        propertyTypeName,
        propertyPrecision,
        propertyReference,
        propertyCoordinates,
        propertyCadastralKey,
        propertyGeometricZone,
        company,
        person,
      ];
}
