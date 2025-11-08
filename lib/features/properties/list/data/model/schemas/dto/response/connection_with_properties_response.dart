import 'package:json_annotation/json_annotation.dart';

part 'connection_with_properties_response.g.dart';

/// ===================================================
/// CONVERSORES SEGUROS
/// ===================================================

/// Convierte int, String, null → String?
String? _toStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  return value.toString();
}

/// Convierte int, String → String (nunca null)
String _toStringNonNull(dynamic value) {
  if (value == null) {
    // Puedes cambiar por '' si prefieres valor por defecto
    throw ArgumentError('Value cannot be null for required ID field');
  }
  return value.toString();
}

/// Convierte a int? (null, int, String)
int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Convierte a double?
double? _toDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Convierte a DateTime?
DateTime? _toDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// ===================================================
/// MODELOS
/// ===================================================

@JsonSerializable(explicitToJson: true)
class Phone {
  @JsonKey(name: 'telefonoid')
  final int telefonoid;

  @JsonKey(name: 'numero')
  final String numero;

  Phone({required this.telefonoid, required this.numero});

  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Email {
  @JsonKey(name: 'correoid')
  final int correoid;

  @JsonKey(name: 'email')
  final String email;

  Email({required this.correoid, required this.email});

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Person {
  @JsonKey(name: 'personId', fromJson: _toStringNonNull)
  final String personId;

  @JsonKey(name: 'firstName')
  final String? firstName;

  @JsonKey(name: 'lastName')
  final String? lastName;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'genderId', fromJson: _toIntOrNull)
  final int? genderId;

  @JsonKey(name: 'parishId', fromJson: _toStringOrNull)
  final String? parishId;

  @JsonKey(name: 'birthDate')
  final String? birthDate;

  @JsonKey(name: 'isDeceased')
  final bool? isDeceased;

  @JsonKey(name: 'professionId', fromJson: _toIntOrNull)
  final int? professionId;

  @JsonKey(name: 'civilStatus', fromJson: _toIntOrNull)
  final int? civilStatus;

  @JsonKey(name: 'emails')
  final List<Email?> emails;

  @JsonKey(name: 'phones')
  final List<Phone?> phones;

  Person({
    required this.personId,
    required this.firstName,
    this.lastName,
    this.address,
    this.country,
    this.genderId,
    this.parishId,
    this.birthDate,
    this.isDeceased,
    this.professionId,
    this.civilStatus,
    required this.emails,
    required this.phones,
  });

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
  Map<String, dynamic> toJson() => _$PersonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Company {
  @JsonKey(name: 'ruc')
  final String ruc;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'clientId')
  final String clientId;

  @JsonKey(name: 'parishId', fromJson: _toStringOrNull)
  final String? parishId;

  @JsonKey(name: 'companyId')
  final int companyId;

  @JsonKey(name: 'businessName')
  final String? businessName;

  @JsonKey(name: 'commercialName')
  final String? commercialName;

  @JsonKey(name: 'emails')
  final List<Email?> emails;

  @JsonKey(name: 'phones')
  final List<Phone?> phones;

  Company({
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

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Property {
  @JsonKey(name: 'propertyId', fromJson: _toStringNonNull)
  final String propertyId;

  @JsonKey(name: 'propertySector')
  final String propertySector;

  @JsonKey(name: 'propertyTypeId', fromJson: _toIntOrNull)
  final int? propertyTypeId;

  @JsonKey(name: 'propertyTypeName')
  final String propertyTypeName;

  @JsonKey(name: 'propertyAddress')
  final String propertyAddress;

  @JsonKey(name: 'propertyAlleyway')
  final String propertyAlleyway;

  @JsonKey(name: 'propertyAltitude', fromJson: _toDoubleOrNull)
  final double? propertyAltitude;

  @JsonKey(name: 'propertyPrecision', fromJson: _toDoubleOrNull)
  final double? propertyPrecision;

  @JsonKey(name: 'propertyReference')
  final String? propertyReference;

  @JsonKey(name: 'propertyCoordinates')
  final String? propertyCoordinates;

  @JsonKey(name: 'propertyCadastralKey')
  final String propertyCadastralKey;

  @JsonKey(name: 'propertyGeometricZone')
  final String? propertyGeometricZone;

  Property({
    required this.propertyId,
    required this.propertySector,
    this.propertyTypeId,
    required this.propertyTypeName,
    required this.propertyAddress,
    required this.propertyAlleyway,
    this.propertyAltitude,
    this.propertyPrecision,
    this.propertyReference,
    this.propertyCoordinates,
    required this.propertyCadastralKey,
    this.propertyGeometricZone,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConnectionWithPropertiesResponse {
  @JsonKey(name: 'connectionId', fromJson: _toStringNonNull)
  final String connectionId;

  @JsonKey(name: 'clientId')
  final String clientId;

  @JsonKey(name: 'connectionRateId', fromJson: _toIntOrNull)
  final int? connectionRateId;

  @JsonKey(name: 'connectionRateName')
  final String connectionRateName;

  @JsonKey(name: 'connectionMeterNumber')
  final String? connectionMeterNumber;

  @JsonKey(name: 'connectionSector', fromJson: _toIntOrNull)
  final int? connectionSector;

  @JsonKey(name: 'connectionAccount', fromJson: _toIntOrNull)
  final int? connectionAccount;

  @JsonKey(name: 'connectionCadastralKey')
  final String connectionCadastralKey;

  @JsonKey(name: 'connectionContractNumber', fromJson: _toStringOrNull)
  final String? connectionContractNumber;

  @JsonKey(name: 'connectionSewerage')
  final bool? connectionSewerage;

  @JsonKey(name: 'connectionStatus')
  final bool? connectionStatus;

  @JsonKey(name: 'connectionAddress')
  final String connectionAddress;

  @JsonKey(name: 'connectionInstallationDate')
  final String? connectionInstallationDate;

  @JsonKey(name: 'connectionPeopleNumber', fromJson: _toIntOrNull)
  final int? connectionPeopleNumber;

  @JsonKey(name: 'connectionZone', fromJson: _toIntOrNull)
  final int? connectionZone;

  @JsonKey(name: 'connectionCoordinates')
  final String? connectionCoordinates;

  @JsonKey(name: 'connectionReference')
  final String? connectionReference;

  @JsonKey(name: 'connectionMetadata')
  final Map<String, dynamic>? connectionMetadata;

  @JsonKey(name: 'connectionAltitude', fromJson: _toDoubleOrNull)
  final double? connectionAltitude;

  @JsonKey(name: 'connectionPrecision', fromJson: _toDoubleOrNull)
  final double? connectionPrecision;

  @JsonKey(name: 'connectionGeolocationDate', fromJson: _toDateTimeOrNull)
  final DateTime? connectionGeolocationDate;

  @JsonKey(name: 'connectionGeometricZone')
  final String? connectionGeometricZone;

  @JsonKey(name: 'propertyCadastralKey')
  final String? propertyCadastralKey;

  @JsonKey(name: 'zoneId', fromJson: _toIntOrNull)
  final int? zoneId;

  @JsonKey(name: 'zoneCode', fromJson: _toStringOrNull)
  final String? zoneCode;

  @JsonKey(name: 'zoneName')
  final String? zoneName;

  @JsonKey(name: 'person')
  final Person? person;

  @JsonKey(name: 'company')
  final Company? company;

  @JsonKey(name: 'properties')
  final List<Property>? properties;

  ConnectionWithPropertiesResponse({
    required this.connectionId,
    required this.clientId,
    this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    this.connectionSector,
    this.connectionAccount,
    required this.connectionCadastralKey,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    required this.connectionAddress,
    this.connectionInstallationDate,
    this.connectionPeopleNumber,
    this.connectionZone,
    this.connectionCoordinates,
    this.connectionReference,
    this.connectionMetadata,
    this.connectionAltitude,
    this.connectionPrecision,
    this.connectionGeolocationDate,
    this.connectionGeometricZone,
    this.propertyCadastralKey,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.person,
    this.company,
    this.properties,
  });

  factory ConnectionWithPropertiesResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ConnectionWithPropertiesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ConnectionWithPropertiesResponseToJson(this);
}
