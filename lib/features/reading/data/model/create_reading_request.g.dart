// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_reading_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReadingRequest _$CreateReadingRequestFromJson(
  Map<String, dynamic> json,
) => CreateReadingRequest(
  connectionId: json['connectionId'] as String,
  sector: (json['sector'] as num).toInt(),
  account: (json['account'] as num).toInt(),
  cadastralKey: json['cadastralKey'] as String,
  sewerRate: (json['sewerRate'] as num).toDouble(),
  previousReading: (json['previousReading'] as num).toDouble(),
  currentReading: (json['currentReading'] as num).toDouble(),
  incomeCode: (json['incomeCode'] as num).toInt(),
  readingValue: (json['readingValue'] as num).toDouble(),
  rentalIncomeCode: (json['rentalIncomeCode'] as num).toInt(),
  novelty: json['novelty'] as String?,
  averageConsumption: (json['averageConsumption'] as num).toDouble(),
  previousMonthReading: json['previousMonthReading'] as String,
);

Map<String, dynamic> _$CreateReadingRequestToJson(
  CreateReadingRequest instance,
) => <String, dynamic>{
  'connectionId': instance.connectionId,
  'sector': instance.sector,
  'account': instance.account,
  'cadastralKey': instance.cadastralKey,
  'sewerRate': instance.sewerRate,
  'previousReading': instance.previousReading,
  'currentReading': instance.currentReading,
  'incomeCode': instance.incomeCode,
  'readingValue': instance.readingValue,
  'rentalIncomeCode': instance.rentalIncomeCode,
  'novelty': instance.novelty,
  'averageConsumption': instance.averageConsumption,
  'previousMonthReading': instance.previousMonthReading,
};
