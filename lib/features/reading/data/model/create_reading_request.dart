import 'package:json_annotation/json_annotation.dart';

part 'create_reading_request.g.dart';

@JsonSerializable()
class CreateReadingRequest {
  final String connectionId;
  final int sector;
  final int account;
  final String cadastralKey;
  final double sewerRate;
  final double previousReading;
  final double currentReading;
  final int incomeCode;
  final double readingValue;
  final int rentalIncomeCode;

  @JsonKey(defaultValue: null)
  final String? novelty;

  final double averageConsumption;
  final String previousMonthReading;

  CreateReadingRequest({
    required this.connectionId,
    required this.sector,
    required this.account,
    required this.cadastralKey,
    required this.sewerRate,
    required this.previousReading,
    required this.currentReading,
    required this.incomeCode,
    required this.readingValue,
    required this.rentalIncomeCode,
    this.novelty,
    required this.averageConsumption,
    required this.previousMonthReading,
  });

  Map<String, dynamic> toJson() => _$CreateReadingRequestToJson(this);
}
