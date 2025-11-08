import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<void> call({
    required String customerId,
    required UpdateCustomerParams params,
  }) async {
    return await repository.updateCustomer(
      customerId: customerId,
      params: params,
    );
  }
}
