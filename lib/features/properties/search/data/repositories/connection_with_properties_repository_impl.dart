import 'package:app_properties/features/properties/search/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';
import 'package:app_properties/features/properties/search/data/mappers/connection_with_properties_mapper.dart';

class ConnectionWithPropertiesRepositoryImpl
    implements ConnectionWithPropertiesRepository {
  final RemoteConnectionWithPropertiesDataSource
  remoteConnectionWithPropertiesDataSource;

  ConnectionWithPropertiesRepositoryImpl(
    this.remoteConnectionWithPropertiesDataSource,
  );

  @override
  Future<ConnectionWithPropertiesEntity>
  getConnectionWithPropertiesByCadastralKey(String cadastralKey) async {
    final dtoResponse = await remoteConnectionWithPropertiesDataSource
        .fetchConnectionWithPropertiesByCadastralKey(cadastralKey);
    return dtoResponse.toEntity();
  }
}
