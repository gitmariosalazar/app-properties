import 'package:app_properties/features/properties/list/domain/entities/connection.dart';

abstract class ConnectionWithPropertiesRepository {
  Future<ConnectionEntity> getConnectionWithPropertiesByCadastralKey(
    String cadastralKey,
  );
}
