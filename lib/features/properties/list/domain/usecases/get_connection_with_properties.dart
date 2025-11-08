import 'package:app_properties/features/properties/list/domain/entities/connection.dart';
import 'package:app_properties/features/properties/list/domain/repositories/connection_with_properties_repository.dart';

class GetConnectionWithProperties {
  final ConnectionWithPropertiesRepository repository;

  GetConnectionWithProperties(this.repository);

  Future<ConnectionEntity> call(String cadastralKey) {
    return repository.getConnectionWithPropertiesByCadastralKey(cadastralKey);
  }
}
