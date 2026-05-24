import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';

class GetConnectionWithProperties {
  final ConnectionWithPropertiesRepository repository;

  GetConnectionWithProperties(this.repository);

  Future<ConnectionWithPropertiesEntity> call(String cadastralKey) {
    return repository.getConnectionWithPropertiesByCadastralKey(cadastralKey);
  }
}

class GetConnection {
  final ConnectionRepository repository;

  GetConnection(this.repository);

  Future<List<ConnectionEntity>> call(String searchValue) {
    return repository.getConnectionByCadastralKeyOrClientIdOrCardId(
      searchValue,
    );
  }
}
