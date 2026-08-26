// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_reading_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateReadingRequest _$UpdateReadingRequestFromJson(
  Map<String, dynamic> json,
) => UpdateReadingRequest(
  previousReading: (json['previousReading'] as num).toDouble(),
  currentReading: (json['currentReading'] as num).toDouble(),
  rentalIncomeCode: (json['rentalIncomeCode'] as num?)?.toInt(),
  novelty: json['novelty'] as String?,
  incomeCode: (json['incomeCode'] as num?)?.toInt(),
  cadastralKey: json['cadastralKey'] as String?,
  sector: (json['sector'] as num?)?.toInt(),
  account: (json['account'] as num?)?.toInt(),
  connectionId: json['connectionId'] as String?,
);

Map<String, dynamic> _$UpdateReadingRequestToJson(
  UpdateReadingRequest instance,
) => <String, dynamic>{
  'previousReading': instance.previousReading,
  'currentReading': instance.currentReading,
  'rentalIncomeCode': instance.rentalIncomeCode,
  'novelty': instance.novelty,
  'incomeCode': instance.incomeCode,
  'cadastralKey': instance.cadastralKey,
  'sector': instance.sector,
  'account': instance.account,
  'connectionId': instance.connectionId,
};
