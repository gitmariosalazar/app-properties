import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/list/domain/entities/contact.dart';

class CompanyEntity extends Equatable {
  final String ruc;
  final String? address;
  final String? country;
  final String clientId;
  final String? parishId;
  final int companyId;
  final String? businessName;
  final String? commercialName;
  final List<EmailEntity?> emails;
  final List<PhoneEntity?> phones;

  const CompanyEntity({
    required this.ruc,
    this.address,
    this.country,
    required this.clientId,
    this.parishId,
    required this.companyId,
    this.businessName,
    this.commercialName,
    required this.emails,
    required this.phones,
  });

  @override
  List<Object?> get props => [
    ruc,
    address,
    country,
    clientId,
    parishId,
    companyId,
    businessName,
    commercialName,
    emails,
    phones,
  ];
}
