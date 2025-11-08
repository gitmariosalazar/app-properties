abstract class CustomerRepository {
  Future<void> updateCustomer({
    required String customerId,
    required UpdateCustomerParams params,
  });
}

class UpdateCustomerParams {
  final String firstName;
  final String lastName;
  final List<String> emails;
  final List<String> phoneNumbers;
  final String dateOfBirth;
  final int sexId;
  final int civilStatus;
  final String address;
  final int professionId;
  final String originCountry;
  final String identificationType;
  final String parishId;
  final bool deceased;

  UpdateCustomerParams({
    required this.firstName,
    required this.lastName,
    required this.emails,
    required this.phoneNumbers,
    required this.dateOfBirth,
    required this.sexId,
    required this.civilStatus,
    required this.address,
    required this.professionId,
    required this.originCountry,
    required this.identificationType,
    required this.parishId,
    required this.deceased,
  });
}
