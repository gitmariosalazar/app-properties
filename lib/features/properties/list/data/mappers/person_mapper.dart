// lib/features/properties/data/mappers/person_mapper.dart

import 'package:app_properties/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:app_properties/features/properties/list/domain/entities/person.dart';
import 'contact_mapper.dart'; // para mapear emails y phones

extension PersonDtoMapper on dto.Person {
  PersonEntity toEntity() {
    return PersonEntity(
      personId: personId,
      firstName: firstName,
      lastName: lastName,
      address: address,
      country: country,
      genderId: genderId,
      parishId: parishId,
      birthDate: birthDate,
      isDeceased: isDeceased,
      professionId: professionId ?? 0,
      civilStatus: civilStatus ?? 0,
      emails: emails.map((e) => e?.toEntity()).toList(),
      phones: phones.map((e) => e?.toEntity()).toList(),
    );
  }
}
