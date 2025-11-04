import 'package:equatable/equatable.dart';

class ObservationEntity extends Equatable {
  final int readingId;
  final String observationTitle;
  final String observationDetail;
  final String registrationDate;
  final String connectionId;
  final double previousReading;
  final double currentReading;
  final int sector;
  final int account;
  final double readingValue;
  final int noveltyReadingTypeId;
  final String noveltyTypeName;
  final String noveltyTypeDescription;
  final String address;
  final String observations;
  final String clientId;
  final String clientName;
  final String? actionRecommended;

  const ObservationEntity({
    required this.readingId,
    required this.observationTitle,
    required this.observationDetail,
    required this.registrationDate,
    required this.connectionId,
    required this.previousReading,
    required this.currentReading,
    required this.sector,
    required this.account,
    required this.readingValue,
    required this.noveltyReadingTypeId,
    required this.noveltyTypeName,
    required this.noveltyTypeDescription,
    required this.address,
    required this.observations,
    required this.clientId,
    required this.clientName,
    this.actionRecommended,
  });

  @override
  List<Object> get props => [
    readingId,
    observationTitle,
    observationDetail,
    registrationDate,
    connectionId,
    previousReading,
    currentReading,
    sector,
    account,
    readingValue,
    noveltyReadingTypeId,
    noveltyTypeName,
    noveltyTypeDescription,
    address,
    observations,
    clientId,
    clientName,
  ];
}
