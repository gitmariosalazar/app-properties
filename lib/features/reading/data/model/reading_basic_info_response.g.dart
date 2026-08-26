// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_basic_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingBasicInfoResponse _$ReadingBasicInfoResponseFromJson(
  Map<String, dynamic> json,
) => ReadingBasicInfoResponse(
  readingId: (json['readingId'] as num?)?.toInt(),
  previousReadingDate: json['previousReadingDate'] as String?,
  cadastralKey: json['cadastralKey'] as String?,
  cardId: json['cardId'] as String?,
  clientName: json['clientName'] as String?,
  address: json['address'] as String?,
  previousReading: (json['previousReading'] as num?)?.toDouble(),
  currentReading: (json['currentReading'] as num?)?.toDouble(),
  sector: (json['sector'] as num?)?.toInt(),
  account: (json['account'] as num?)?.toInt(),
  readingValue: (json['readingValue'] as num?)?.toDouble(),
  averageConsumption: (json['averageConsumption'] as num?)?.toDouble(),
  meterNumber: json['meterNumber'] as String?,
  rateId: (json['rateId'] as num?)?.toInt(),
  rateName: json['rateName'] as String?,
);

Map<String, dynamic> _$ReadingBasicInfoResponseToJson(
  ReadingBasicInfoResponse instance,
) => <String, dynamic>{
  'readingId': instance.readingId,
  'previousReadingDate': instance.previousReadingDate,
  'cadastralKey': instance.cadastralKey,
  'cardId': instance.cardId,
  'clientName': instance.clientName,
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
};
