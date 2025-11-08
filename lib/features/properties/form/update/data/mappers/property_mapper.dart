// lib/features/properties/put/data/mappers/property_mapper.dart
import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_property_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';

class PropertyMapper {
  static UpdatePropertyRequest toRequest(
    UpdatePropertyParams params,
    String cadastralKey,
  ) {
    return UpdatePropertyRequest(
      propertyCadastralKey: cadastralKey,
      propertyClientId: params.propertyClientId,
      propertyAlleyway: params.propertyAlleyway,
      propertySector: params.propertySector,
      propertyAddress: params.propertyAddress,
      propertyLandArea: params.propertyLandArea,
      propertyConstructionArea: params.propertyConstructionArea,
      propertyLandValue: params.propertyLandValue,
      propertyConstructionValue: params.propertyConstructionValue,
      propertyCommercialValue: params.propertyCommercialValue,
      longitude: params.longitude,
      latitude: params.latitude,
      propertyReference: params.propertyReference,
      propertyAltitude: params.propertyAltitude,
      propertyPrecision: params.propertyPrecision,
      propertyTypeId: params.propertyTypeId,
    );
  }
}
