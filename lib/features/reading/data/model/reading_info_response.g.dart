// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phone _$PhoneFromJson(Map<String, dynamic> json) => Phone(
  telefonoid: (json['telefonoid'] as num?)?.toInt(),
  numero: json['numero'] as String?,
);

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
  'telefonoid': instance.telefonoid,
  'numero': instance.numero,
};

Email _$EmailFromJson(Map<String, dynamic> json) => Email(
  correoid: (json['correoid'] as num?)?.toInt(),
  email: json['email'] as String?,
);

Map<String, dynamic> _$EmailToJson(Email instance) => <String, dynamic>{
  'correoid': instance.correoid,
  'email': instance.email,
};

ConnectionLocationDto _$ConnectionLocationDtoFromJson(
  Map<String, dynamic> json,
) => ConnectionLocationDto(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ConnectionLocationDtoToJson(
  ConnectionLocationDto instance,
) => <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

ReadingInfoResponse _$ReadingInfoResponseFromJson(Map<String, dynamic> json) =>
    ReadingInfoResponse(
      readingId: (json['readingId'] as num?)?.toInt(),
      previousReadingDate: json['previousReadingDate'] as String?,
      readingTime: json['readingTime'] as String?,
      cadastralKey: json['cadastralKey'] as String?,
      cardId: json['cardId'] as String?,
      clientName: json['clientName'] as String?,
      clientPhones:
          (json['clientPhones'] as List<dynamic>?)
              ?.map((e) => Phone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      clientEmails:
          (json['clientEmails'] as List<dynamic>?)
              ?.map((e) => Email.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      address: json['address'] as String?,
      previousReading: json['previousReading'] as String?,
      currentReading: json['currentReading'] as String?,
      sector: (json['sector'] as num?)?.toInt(),
      account: (json['account'] as num?)?.toInt(),
      readingValue: json['readingValue'] as String? ?? '',
      averageConsumption: json['averageConsumption'] as String? ?? '',
      meterNumber: json['meterNumber'] as String?,
      rateId: (json['rateId'] as num?)?.toInt(),
      rateName: json['rateName'] as String?,
      hasCurrentReading: json['hasCurrentReading'] as bool? ?? false,
      monthReading: json['monthReading'] as String?,
      startDatePeriod: json['startDatePeriod'] as String?,
      endDatePeriod: json['endDatePeriod'] as String?,
      connectionStateId: (json['connectionStateId'] as num?)?.toInt(),
      connectionStateName: json['connectionStateName'] as String?,
      connectionStateDescription: json['connectionStateDescription'] as String?,
      permitReading: json['permitReading'] as bool?,
      connectionLocation: json['connectionLocation'] == null
          ? null
          : ConnectionLocationDto.fromJson(
              json['connectionLocation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ReadingInfoResponseToJson(
  ReadingInfoResponse instance,
) => <String, dynamic>{
  'readingId': instance.readingId,
  'previousReadingDate': instance.previousReadingDate,
  'readingTime': instance.readingTime,
  'cadastralKey': instance.cadastralKey,
  'cardId': instance.cardId,
  'clientName': instance.clientName,
  'clientPhones': instance.clientPhones?.map((e) => e.toJson()).toList(),
  'clientEmails': instance.clientEmails?.map((e) => e.toJson()).toList(),
  'address': instance.address,
  'previousReading': instance.previousReading,
  'currentReading': instance.currentReading,
  'sector': instance.sector,
  'account': instance.account,
  'readingValue': instance.readingValue,
  'averageConsumption': instance.averageConsumption,
  'meterNumber': instance.meterNumber,
  'rateId': instance.rateId,
  'rateName': instance.rateName,
  'hasCurrentReading': instance.hasCurrentReading,
  'monthReading': instance.monthReading,
  'startDatePeriod': instance.startDatePeriod,
  'endDatePeriod': instance.endDatePeriod,
  'connectionStateId': instance.connectionStateId,
  'connectionStateName': instance.connectionStateName,
  'connectionStateDescription': instance.connectionStateDescription,
  'permitReading': instance.permitReading,
  'connectionLocation': instance.connectionLocation?.toJson(),
};
