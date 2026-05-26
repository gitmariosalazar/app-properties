import 'package:app_properties/features/properties/search/domain/entities/property_with_client.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';

class FindPropertyWithClient {
  final ConnectionRepository repository;

  FindPropertyWithClient(this.repository);

  Future<List<PropertyWithClientEntity>> call(
    String searchValue, {
    int? limit,
    int? offset,
  }) {
    return repository.findPropertyWithClientByCadastralKeyOrCardIdOrLikeName(
      searchValue,
      limit: limit,
      offset: offset,
    );
  }
}
