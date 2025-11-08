// lib/features/properties/put/data/repositories/connection_repository_impl.dart
import 'package:app_properties/features/properties/form/update/data/datasources/connection_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/connection_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/connection_repository.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionRemoteDataSource remoteDataSource;

  ConnectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionParams params,
  }) async {
    final request = ConnectionMapper.toRequest(params, connectionId);
    await remoteDataSource.updateConnection(
      connectionId: connectionId,
      request: request,
    );
  }
}
