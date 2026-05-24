import 'package:app_properties/features/properties/search/domain/entities/connection.dart';

abstract class ConnectionWithPropertiesRepository {
  Future<ConnectionWithPropertiesEntity>
  getConnectionWithPropertiesByCadastralKey(String cadastralKey);
}

abstract class ConnectionRepository {
  Future<List<ConnectionEntity>> getConnectionByCadastralKeyOrClientIdOrCardId(
    String searchValue,
  );
}
