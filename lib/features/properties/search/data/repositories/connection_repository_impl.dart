import 'package:app_properties/features/properties/search/data/datasources/remote_connection_datasource.dart';
import 'package:app_properties/features/properties/search/data/mappers/connection_mapper.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final RemoteConnectionDataSource remoteConnectionDataSource;

  ConnectionRepositoryImpl(this.remoteConnectionDataSource);

  @override
  Future<List<ConnectionEntity>> getConnectionByCadastralKeyOrClientIdOrCardId(
    String searchValue,
  ) async {
    final dtoResponse = await remoteConnectionDataSource
        .getConnectionByCadastralKeyOrClientIdOrCardId(searchValue);
    return dtoResponse.map((e) => e.toEntity()).toList();
  }
}
