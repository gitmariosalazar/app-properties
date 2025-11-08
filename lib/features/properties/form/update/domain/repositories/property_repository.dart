abstract class PropertyRepository {
  Future<void> updateProperty({
    required String cadastralKey,
    required UpdatePropertyParams params,
  });
}

class UpdatePropertyParams {
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

  UpdatePropertyParams({
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
}
