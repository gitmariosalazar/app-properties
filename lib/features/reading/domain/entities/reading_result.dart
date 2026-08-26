import 'package:equatable/equatable.dart';

class ReadingResult extends Equatable {
  final int? readingId;
  final String? connectionId;
  final DateTime? readingDate;
  final String? readingTime;
  final int? sector;
  final int? account;
  final String? cadastralKey;
  final double? readingValue;
  final double? sewerRate;
  final double? previousReading;
  final double? currentReading;
  final int? rentalIncomeCode;
  final String? novelty;
  final int? incomeCode;

  const ReadingResult({
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

  @override
  List<Object?> get props => [
    readingId,
    connectionId,
    readingDate,
    readingTime,
    sector,
    account,
    cadastralKey,
    readingValue,
    sewerRate,
    previousReading,
    currentReading,
    rentalIncomeCode,
    novelty,
    incomeCode,
  ];
}
