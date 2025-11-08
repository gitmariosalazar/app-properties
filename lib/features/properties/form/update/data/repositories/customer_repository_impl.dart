import 'package:app_properties/features/properties/form/update/data/datasources/customer_remote_data_source.dart';
import 'package:app_properties/features/properties/form/update/data/mappers/customer_mapper.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateCustomer({
    required String customerId,
    required UpdateCustomerParams params,
  }) async {
    final request = CustomerMapper.toUpdateRequest(params);
    await remoteDataSource.updateCustomer(
      customerId: customerId,
      request: request,
    );
  }
}
