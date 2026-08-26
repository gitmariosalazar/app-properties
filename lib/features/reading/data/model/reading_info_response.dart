// lib/features/scan/data/models/reading_info_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'reading_info_response.g.dart';

@JsonSerializable()
class Phone {
  @JsonKey(name: 'telefonoid')
  final int? telefonoid;

  @JsonKey(name: 'numero')
  final String? numero;

  Phone({this.telefonoid, this.numero});

  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}

@JsonSerializable()
class Email {
  @JsonKey(name: 'correoid')
  final int? correoid;

  @JsonKey(name: 'email')
  final String? email;

  Email({this.correoid, this.email});

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

@JsonSerializable()
class ConnectionLocationDto {
  @JsonKey(name: 'lat')
  final double? lat;

  @JsonKey(name: 'lng')
  final double? lng;

  ConnectionLocationDto({this.lat, this.lng});

  factory ConnectionLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ConnectionLocationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectionLocationDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReadingInfoResponse {
  @JsonKey(name: 'readingId')
  final int? readingId;

  @JsonKey(name: 'previousReadingDate', defaultValue: null)
  final String? previousReadingDate;

  @JsonKey(name: 'readingTime', defaultValue: null)
  final String? readingTime;

  @JsonKey(name: 'cadastralKey')
  final String? cadastralKey;

  @JsonKey(name: 'cardId')
  final String? cardId;

  @JsonKey(name: 'clientName')
  final String? clientName;

  @JsonKey(name: 'clientPhones', defaultValue: <Phone>[])
  final List<Phone>? clientPhones;

  @JsonKey(name: 'clientEmails', defaultValue: <Email>[])
  final List<Email>? clientEmails;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'previousReading')
  final String? previousReading;

  @JsonKey(name: 'currentReading', defaultValue: null)
  final String? currentReading;

  @JsonKey(name: 'sector')
  final int? sector;

  @JsonKey(name: 'account')
  final int? account;

  @JsonKey(name: 'readingValue', defaultValue: '')
  final String? readingValue;

  @JsonKey(name: 'averageConsumption', defaultValue: '')
  final String? averageConsumption;

  @JsonKey(name: 'meterNumber', defaultValue: null)
  final String? meterNumber;

  @JsonKey(name: 'rateId')
  final int? rateId;

  @JsonKey(name: 'rateName')
  final String? rateName;

  @JsonKey(name: 'hasCurrentReading', defaultValue: false)
  final bool? hasCurrentReading;

  @JsonKey(name: 'monthReading')
  final String? monthReading;

  @JsonKey(name: 'startDatePeriod', defaultValue: null)
  final String? startDatePeriod;

  @JsonKey(name: 'endDatePeriod', defaultValue: null)
  final String? endDatePeriod;

  @JsonKey(name: 'connectionStateId', defaultValue: null)
  final int? connectionStateId;

  @JsonKey(name: 'connectionStateName', defaultValue: null)
  final String? connectionStateName;

  @JsonKey(name: 'connectionStateDescription', defaultValue: null)
  final String? connectionStateDescription;

  @JsonKey(name: 'permitReading', defaultValue: null)
  final bool? permitReading;

  @JsonKey(name: 'connectionLocation', defaultValue: null)
  final ConnectionLocationDto? connectionLocation;

  ReadingInfoResponse({
    this.readingId,
    this.previousReadingDate,
    this.readingTime,
    this.cadastralKey,
    this.cardId,
    this.clientName,
    this.clientPhones,
    this.clientEmails,
    this.address,
    this.previousReading,
    this.currentReading,
    this.sector,
    this.account,
    this.readingValue,
    this.averageConsumption,
    this.meterNumber,
    this.rateId,
    this.rateName,
    this.hasCurrentReading,
    this.monthReading,
    this.startDatePeriod,
    this.endDatePeriod,
    this.connectionStateId,
    this.connectionStateName,
    this.connectionStateDescription,
    this.permitReading,
    this.connectionLocation,
  });

  factory ReadingInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadingInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingInfoResponseToJson(this);
}
