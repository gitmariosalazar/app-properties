import 'package:json_annotation/json_annotation.dart';

part 'update_customer_request.g.dart'; // For json_serializable

@JsonSerializable()
class UpdateCustomerRequest {
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

  UpdateCustomerRequest({
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

  factory UpdateCustomerRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCustomerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCustomerRequestToJson(this);
}
