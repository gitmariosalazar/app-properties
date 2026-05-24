import 'package:app_properties/features/properties/search/data/datasources/remote_connection_with_properties_datasource.dart';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/repositories/connection_with_properties_repository.dart';
import 'package:app_properties/features/properties/search/data/mappers/connection_with_properties_mapper.dart';
import 'package:app_properties/features/properties/search/data/datasources/local_connection_datasource.dart';
import 'package:app_properties/core/network/network_info.dart';

class ConnectionWithPropertiesRepositoryImpl
    implements ConnectionWithPropertiesRepository {
  final RemoteConnectionWithPropertiesDataSource
  remoteConnectionWithPropertiesDataSource;
  final LocalConnectionDataSource localConnectionDataSource;
  final NetworkInfo networkInfo;

  ConnectionWithPropertiesRepositoryImpl({
    required this.remoteConnectionWithPropertiesDataSource,
    required this.localConnectionDataSource,
    required this.networkInfo,
  });

  @override
  Future<ConnectionWithPropertiesEntity>
  getConnectionWithPropertiesByCadastralKey(String cadastralKey) async {
    if (await networkInfo.isConnected) {
      try {
        final dtoResponse = await remoteConnectionWithPropertiesDataSource
            .fetchConnectionWithPropertiesByCadastralKey(cadastralKey);
        
        // Cachear localmente
        await localConnectionDataSource.cacheConnectionWithProperties(cadastralKey, dtoResponse);
        
        return dtoResponse.toEntity();
      } catch (e) {
        // Fallback local en caso de error remoto temporal
        final cached = await localConnectionDataSource.getCachedConnectionWithProperties(cadastralKey);
        if (cached != null) {
          return cached.toEntity();
        }
        rethrow;
      }
    } else {
      // Offline fallback
      final cached = await localConnectionDataSource.getCachedConnectionWithProperties(cadastralKey);
      if (cached != null) {
        return cached.toEntity();
      }
      throw Exception(
        'Sin conexión a internet y no se encontró registro local detallado para la clave catastral: $cadastralKey',
      );
    }
  }
}
