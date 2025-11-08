import 'package:app_properties/features/properties/form/update/data/models/dto/request/update_customer_request.dart';
import 'package:app_properties/features/properties/form/update/domain/repositories/customer_repository.dart';

class CustomerMapper {
  static UpdateCustomerRequest toUpdateRequest(UpdateCustomerParams params) {
    return UpdateCustomerRequest(
      firstName: params.firstName,
      lastName: params.lastName,
      emails: params.emails,
      phoneNumbers: params.phoneNumbers,
      dateOfBirth: params.dateOfBirth,
      sexId: params.sexId,
      civilStatus: params.civilStatus,
      address: params.address,
      professionId: params.professionId,
      originCountry: params.originCountry,
      identificationType: params.identificationType,
      parishId: params.parishId,
      deceased: params.deceased,
    );
  }
}
