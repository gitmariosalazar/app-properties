// lib/features/scan/domain/entities/reading.dart
import 'package:equatable/equatable.dart';

class Phone extends Equatable {
  final String? number;
  const Phone(this.number);
  @override
  List<Object?> get props => [number];
}

class Email extends Equatable {
  final String? email;
  const Email(this.email);
  @override
  List<Object?> get props => [email];
}

class ConnectionLocation extends Equatable {
  final double? lat;
  final double? lng;

  const ConnectionLocation({this.lat, this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class Reading extends Equatable {
  final int? readingId;
  final DateTime? previousReadingDate;
  final DateTime? readingTime;
  final String? cadastralKey;
  final String? cardId;
  final String? clientName;
  final List<Phone>? phones;
  final List<Email>? emails;
  final String? address;
  final String?
  previousReading; // Changed to String to match DTO if that was the case, or should be double? DTO says String.
  final String? currentReading;
  final int? sector;
  final int? account;
  final String? readingValue;
  final String? averageConsumption;
  final String? meterNumber;
  final int? rateId;
  final String? rateName;
  final bool? hasCurrentReading;
  final String? monthReading;
  final DateTime? startDatePeriod;
  final DateTime? endDatePeriod;
  final int? connectionStateId;
  final String? connectionStateName;
  final String? connectionStateDescription;
  final bool? permitReading;
  final ConnectionLocation? connectionLocation;

  const Reading({
    this.readingId,
    this.previousReadingDate,
    this.readingTime,
    this.cadastralKey,
    this.cardId,
    this.clientName,
    this.phones,
    this.emails,
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
    this.hasCurrentReading,
    this.monthReading,
    this.startDatePeriod,
    this.endDatePeriod,
    this.connectionStateId,
    this.connectionStateName,
    this.connectionStateDescription,
    this.permitReading,
    this.connectionLocation,
  });

  @override
  List<Object?> get props => [
    readingId,
    previousReadingDate,
    readingTime,
    cadastralKey,
    cardId,
    clientName,
    phones,
    emails,
    address,
    previousReading,
    currentReading,
    sector,
    account,
    readingValue,
    averageConsumption,
    meterNumber,
    rateId,
    rateName,
    hasCurrentReading,
    monthReading,
    startDatePeriod,
    endDatePeriod,
    connectionStateId,
    connectionStateName,
    connectionStateDescription,
    permitReading,
    connectionLocation,
  ];
}
