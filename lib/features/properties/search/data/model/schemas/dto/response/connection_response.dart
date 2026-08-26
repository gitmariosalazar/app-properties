import 'package:json_annotation/json_annotation.dart';

part 'connection_response.g.dart';

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
    return '';
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

/// Convierte a bool? — acepta bool, String ('true','false','1','0') e int (1, 0)
bool? _toBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return null;
}

/// ===================================================
/// MODELOS
/// ===================================================

@JsonSerializable(explicitToJson: true)
class Phone {
  @JsonKey(name: 'telefonoid', fromJson: _toIntOrNull)
  final int? telefonoid;

  @JsonKey(name: 'numero')
  final String? numero;

  Phone({this.telefonoid, this.numero});

  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Email {
  @JsonKey(name: 'correoid', fromJson: _toIntOrNull)
  final int? correoid;

  @JsonKey(name: 'email')
  final String? email;

  Email({this.correoid, this.email});

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Person {
  @JsonKey(name: 'personId', fromJson: _toStringNonNull)
  final String personId;

  @JsonKey(name: 'firstName', fromJson: _toStringOrNull)
  final String? firstName;

  @JsonKey(name: 'lastName', fromJson: _toStringOrNull)
  final String? lastName;

  @JsonKey(name: 'address', fromJson: _toStringOrNull)
  final String? address;

  @JsonKey(name: 'country', fromJson: _toStringOrNull)
  final String? country;

  @JsonKey(name: 'genderId', fromJson: _toIntOrNull)
  final int? genderId;

  @JsonKey(name: 'parishId', fromJson: _toStringOrNull)
  final String? parishId;

  @JsonKey(name: 'birthDate', fromJson: _toStringOrNull)
  final String? birthDate;

  @JsonKey(name: 'isDeceased', fromJson: _toBoolOrNull)
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
  @JsonKey(name: 'ruc', fromJson: _toStringNonNull)
  final String ruc;

  @JsonKey(name: 'address', fromJson: _toStringOrNull)
  final String? address;

  @JsonKey(name: 'country', fromJson: _toStringOrNull)
  final String? country;

  @JsonKey(name: 'clientId', fromJson: _toStringNonNull)
  final String clientId;

  @JsonKey(name: 'parishId', fromJson: _toStringOrNull)
  final String? parishId;

  @JsonKey(name: 'companyId', fromJson: _toIntOrNull)
  final int? companyId;

  @JsonKey(name: 'businessName', fromJson: _toStringOrNull)
  final String? businessName;

  @JsonKey(name: 'commercialName', fromJson: _toStringOrNull)
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
    this.companyId,
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

  @JsonKey(name: 'propertySector', fromJson: _toStringNonNull)
  final String propertySector;

  @JsonKey(name: 'propertyTypeId', fromJson: _toIntOrNull)
  final int? propertyTypeId;

  @JsonKey(name: 'propertyTypeName', fromJson: _toStringNonNull)
  final String propertyTypeName;

  @JsonKey(name: 'propertyAddress', fromJson: _toStringNonNull)
  final String propertyAddress;

  @JsonKey(name: 'propertyAlleyway', fromJson: _toStringNonNull)
  final String propertyAlleyway;

  @JsonKey(name: 'propertyAltitude', fromJson: _toDoubleOrNull)
  final double? propertyAltitude;

  @JsonKey(name: 'propertyPrecision', fromJson: _toDoubleOrNull)
  final double? propertyPrecision;

  @JsonKey(name: 'propertyReference', fromJson: _toStringOrNull)
  final String? propertyReference;

  @JsonKey(name: 'propertyCoordinates', fromJson: _toStringOrNull)
  final String? propertyCoordinates;

  @JsonKey(name: 'propertyCadastralKey', fromJson: _toStringNonNull)
  final String propertyCadastralKey;

  @JsonKey(name: 'propertyGeometricZone', fromJson: _toStringOrNull)
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
class LastReading {
  @JsonKey(name: 'cadastralKey')
  final String? cadastralKey;

  @JsonKey(name: 'readingDate', fromJson: _toDateTimeOrNull)
  final DateTime? readingDate;

  @JsonKey(name: 'readingTime', fromJson: _toStringOrNull)
  final String? readingTime;

  @JsonKey(name: 'readingMonth', fromJson: _toStringOrNull)
  final String? readingMonth;

  @JsonKey(name: 'readingValueCurrent', fromJson: _toDoubleOrNull)
  final double? readingValueCurrent;

  @JsonKey(name: 'readingValuePreview', fromJson: _toDoubleOrNull)
  final double? readingValuePreview;

  @JsonKey(name: 'novelty')
  final String? novelty;

  LastReading({
    this.cadastralKey,
    this.readingDate,
    this.readingTime,
    this.readingMonth,
    this.readingValueCurrent,
    this.readingValuePreview,
    this.novelty,
  });

  factory LastReading.fromJson(Map<String, dynamic> json) =>
      _$LastReadingFromJson(json);
  Map<String, dynamic> toJson() => _$LastReadingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ConnectionResponse {
  @JsonKey(name: 'connectionId', fromJson: _toStringNonNull)
  final String connectionId;

  @JsonKey(name: 'clientId', fromJson: _toStringNonNull)
  final String clientId;

  @JsonKey(name: 'connectionRateId', fromJson: _toIntOrNull)
  final int? connectionRateId;

  @JsonKey(name: 'connectionRateName', fromJson: _toStringNonNull)
  final String connectionRateName;

  @JsonKey(name: 'connectionMeterNumber', fromJson: _toStringOrNull)
  final String? connectionMeterNumber;

  @JsonKey(name: 'connectionMeterNumberPreview', fromJson: _toStringOrNull)
  final String? connectionMeterNumberPreview;

  @JsonKey(name: 'connectionMeterNumberCurrent', fromJson: _toStringOrNull)
  final String? connectionMeterNumberCurrent;

  @JsonKey(name: 'connectionSector', fromJson: _toIntOrNull)
  final int? connectionSector;

  @JsonKey(name: 'connectionAccount', fromJson: _toIntOrNull)
  final int? connectionAccount;

  @JsonKey(name: 'connectionCadastralKey', fromJson: _toStringNonNull)
  final String connectionCadastralKey;

  @JsonKey(name: 'connectionContractNumber', fromJson: _toStringOrNull)
  final String? connectionContractNumber;

  @JsonKey(name: 'connectionSewerage', fromJson: _toBoolOrNull)
  final bool? connectionSewerage;

  @JsonKey(name: 'connectionStatus', fromJson: _toBoolOrNull)
  final bool? connectionStatus;

  @JsonKey(name: 'connectionStateId', fromJson: _toIntOrNull)
  final int? connectionStateId;

  @JsonKey(name: 'connectionIsReadable', fromJson: _toBoolOrNull)
  final bool? connectionIsReadable;

  @JsonKey(name: 'connectionAddress', fromJson: _toStringNonNull)
  final String connectionAddress;

  @JsonKey(name: 'connectionInstallationDate', fromJson: _toStringOrNull)
  final String? connectionInstallationDate;

  @JsonKey(name: 'connectionPeopleNumber', fromJson: _toIntOrNull)
  final int? connectionPeopleNumber;

  @JsonKey(name: 'connectionZone', fromJson: _toIntOrNull)
  final int? connectionZone;

  @JsonKey(name: 'connectionCoordinates', fromJson: _toStringOrNull)
  final String? connectionCoordinates;

  @JsonKey(name: 'connectionReference', fromJson: _toStringOrNull)
  final String? connectionReference;

  @JsonKey(name: 'connectionMetadata')
  final Map<String, dynamic>? connectionMetadata;

  @JsonKey(name: 'connectionAltitude', fromJson: _toDoubleOrNull)
  final double? connectionAltitude;

  @JsonKey(name: 'connectionPrecision', fromJson: _toDoubleOrNull)
  final double? connectionPrecision;

  @JsonKey(name: 'connectionGeolocationDate', fromJson: _toDateTimeOrNull)
  final DateTime? connectionGeolocationDate;

  @JsonKey(name: 'connectionGeometricZone', fromJson: _toStringOrNull)
  final String? connectionGeometricZone;

  @JsonKey(name: 'propertyCadastralKey', fromJson: _toStringOrNull)
  final String? propertyCadastralKey;

  @JsonKey(name: 'zoneId', fromJson: _toIntOrNull)
  final int? zoneId;

  @JsonKey(name: 'zoneCode', fromJson: _toStringOrNull)
  final String? zoneCode;

  @JsonKey(name: 'zoneName', fromJson: _toStringOrNull)
  final String? zoneName;

  @JsonKey(name: 'person')
  final Person? person;

  @JsonKey(name: 'company')
  final Company? company;

  @JsonKey(name: 'property')
  final Property? property;

  @JsonKey(name: 'lastReadings')
  final List<LastReading>? lastReadings;

  ConnectionResponse({
    required this.connectionId,
    required this.clientId,
    this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    this.connectionMeterNumberPreview,
    this.connectionMeterNumberCurrent,
    this.connectionSector,
    this.connectionAccount,
    required this.connectionCadastralKey,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    this.connectionStateId,
    this.connectionIsReadable,
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
    this.property,
    this.lastReadings,
  });

  factory ConnectionResponse.fromJson(Map<String, dynamic> json) =>
      _$ConnectionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionResponseToJson(this);
}
