// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingResponse _$ReadingResponseFromJson(Map<String, dynamic> json) =>
    ReadingResponse(
      readingId: (json['readingId'] as num?)?.toInt(),
      connectionId: json['connectionId'] as String?,
      readingDate: json['readingDate'] as String?,
      readingTime: json['readingTime'] as String?,
      sector: (json['sector'] as num?)?.toInt(),
      account: (json['account'] as num?)?.toInt(),
      cadastralKey: json['cadastralKey'] as String?,
      readingValue: (json['readingValue'] as num?)?.toDouble(),
      sewerRate: (json['sewerRate'] as num?)?.toDouble(),
      previousReading: (json['previousReading'] as num?)?.toDouble(),
      currentReading: (json['currentReading'] as num?)?.toDouble(),
      rentalIncomeCode: (json['rentalIncomeCode'] as num?)?.toInt(),
      novelty: json['novelty'] as String?,
      incomeCode: (json['incomeCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadingResponseToJson(ReadingResponse instance) =>
    <String, dynamic>{
      'readingId': instance.readingId,
      'connectionId': instance.connectionId,
      'readingDate': instance.readingDate,
      'readingTime': instance.readingTime,
      'sector': instance.sector,
      'account': instance.account,
      'cadastralKey': instance.cadastralKey,
      'readingValue': instance.readingValue,
      'sewerRate': instance.sewerRate,
      'previousReading': instance.previousReading,
      'currentReading': instance.currentReading,
      'rentalIncomeCode': instance.rentalIncomeCode,
      'novelty': instance.novelty,
      'incomeCode': instance.incomeCode,
    };
