import 'package:json_annotation/json_annotation.dart';

part 'update_reading_request.g.dart';

@JsonSerializable()
class UpdateReadingRequest {
  final double previousReading;
  final double currentReading;

  @JsonKey(defaultValue: null)
  final int? rentalIncomeCode;

  @JsonKey(defaultValue: null)
  final String? novelty;

  @JsonKey(defaultValue: null)
  final int? incomeCode;

  @JsonKey(defaultValue: null)
  final String? cadastralKey;

  @JsonKey(defaultValue: null)
  final int? sector;

  @JsonKey(defaultValue: null)
  final int? account;

  @JsonKey(defaultValue: null)
  final String? connectionId;

  UpdateReadingRequest({
    required this.previousReading,
    required this.currentReading,
    this.rentalIncomeCode,
    this.novelty,
    this.incomeCode,
    this.cadastralKey,
    this.sector,
    this.account,
    this.connectionId,
  });

  Map<String, dynamic> toJson() => _$UpdateReadingRequestToJson(this);
}
