import 'package:app_properties/features/properties/list/domain/entities/contact.dart';
import 'package:app_properties/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;

extension PhoneDtoMapper on dto.Phone {
  PhoneEntity toEntity() {
    return PhoneEntity(telefonoid, numero);
  }
}

extension EmailDtoMapper on dto.Email {
  EmailEntity toEntity() {
    return EmailEntity(correoid, email);
  }
}
