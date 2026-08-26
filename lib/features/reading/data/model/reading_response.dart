import 'package:json_annotation/json_annotation.dart';

part 'reading_response.g.dart';

@JsonSerializable()
class ReadingResponse {
  final int? readingId;
  final String? connectionId;

  @JsonKey(defaultValue: null)
  final String? readingDate;

  @JsonKey(defaultValue: null)
  final String? readingTime;

  final int? sector;
  final int? account;
  final String? cadastralKey;

  @JsonKey(defaultValue: null)
  final double? readingValue;

  @JsonKey(defaultValue: null)
  final double? sewerRate;

  @JsonKey(defaultValue: null)
  final double? previousReading;

  @JsonKey(defaultValue: null)
  final double? currentReading;

  @JsonKey(defaultValue: null)
  final int? rentalIncomeCode;

  @JsonKey(defaultValue: null)
  final String? novelty;

  @JsonKey(defaultValue: null)
  final int? incomeCode;

  ReadingResponse({
    this.readingId,
    this.connectionId,
    this.readingDate,
    this.readingTime,
    this.sector,
    this.account,
    this.cadastralKey,
    this.readingValue,
    this.sewerRate,
    this.previousReading,
    this.currentReading,
    this.rentalIncomeCode,
    this.novelty,
    this.incomeCode,
  });

  factory ReadingResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingResponseToJson(this);
}
