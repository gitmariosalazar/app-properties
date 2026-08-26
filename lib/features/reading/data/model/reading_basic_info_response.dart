import 'package:json_annotation/json_annotation.dart';

part 'reading_basic_info_response.g.dart';

@JsonSerializable()
class ReadingBasicInfoResponse {
  final int? readingId;

  @JsonKey(defaultValue: null)
  final String? previousReadingDate;

  final String? cadastralKey;
  final String? cardId;
  final String? clientName;
  final String? address;
  final double? previousReading;

  @JsonKey(defaultValue: null)
  final double? currentReading;

  final int? sector;
  final int? account;
  final double? readingValue;
  final double? averageConsumption;
  final String? meterNumber;
  final int? rateId;
  final String? rateName;

  ReadingBasicInfoResponse({
    this.readingId,
    this.previousReadingDate,
    this.cadastralKey,
    this.cardId,
    this.clientName,
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
  });

  factory ReadingBasicInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadingBasicInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingBasicInfoResponseToJson(this);
}
