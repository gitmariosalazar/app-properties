import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/entities/property_with_client.dart';

abstract class ConnectionWithPropertiesRepository {
  Future<ConnectionWithPropertiesEntity>
  getConnectionWithPropertiesByCadastralKey(String cadastralKey);
}

abstract class ConnectionRepository {
  Future<List<ConnectionEntity>> getConnectionByCadastralKeyOrClientIdOrCardId(
    String searchValue,
  );

  Future<List<PropertyWithClientEntity>> findPropertyWithClientByCadastralKeyOrCardIdOrLikeName(
    String searchValue, {
    int? limit,
    int? offset,
  });
}
