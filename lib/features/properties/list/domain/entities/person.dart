import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/list/domain/entities/contact.dart';

class PersonEntity extends Equatable {
  final String personId;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? country;
  final int? genderId;
  final String? parishId;
  final String? birthDate;
  final bool? isDeceased;
  final int professionId;
  final int civilStatus;
  final List<EmailEntity?> emails;
  final List<PhoneEntity?> phones;

  const PersonEntity({
    required this.personId,
    this.firstName,
    this.lastName,
    this.address,
    this.country,
    this.genderId,
    this.parishId,
    this.birthDate,
    this.isDeceased,
    required this.professionId,
    required this.civilStatus,
    required this.emails,
    required this.phones,
  });

  @override
  List<Object?> get props => [
    personId,
    firstName,
    lastName,
    address,
    country,
    genderId,
    parishId,
    birthDate,
    isDeceased,
    professionId,
    civilStatus,
    emails,
    phones,
  ];
}
