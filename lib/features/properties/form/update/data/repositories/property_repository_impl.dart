// lib/features/properties/put/data/repositories/property_repository_impl.dart
import 'package:app_properties/features/properties/form/update/data/datasources/property_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/property_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateProperty({
    required String cadastralKey,
    required UpdatePropertyParams params,
  }) async {
    final request = PropertyMapper.toRequest(params, cadastralKey);
    await remoteDataSource.updateProperty(
      cadastralKey: cadastralKey,
      request: request,
    );
  }
}
