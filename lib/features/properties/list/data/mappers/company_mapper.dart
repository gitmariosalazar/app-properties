// lib/features/properties/data/mappers/company_mapper.dart

import 'package:app_properties/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:app_properties/features/properties/list/domain/entities/company.dart';
import 'contact_mapper.dart';

extension CompanyDtoMapper on dto.Company {
  CompanyEntity toEntity() {
    return CompanyEntity(
      ruc: ruc,
      address: address,
      country: country,
      clientId: clientId,
      parishId: parishId,
      companyId: companyId,
      businessName: businessName,
      commercialName: commercialName,
      emails: emails.map((e) => e?.toEntity()).toList(),
      phones: phones.map((e) => e?.toEntity()).toList(),
    );
  }
}
