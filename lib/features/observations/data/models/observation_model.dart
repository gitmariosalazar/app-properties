import 'package:app_properties/features/observations/domain/entities/observation_entity.dart';
import 'package:app_properties/utils/date_utils.dart';

class ObservationModel extends ObservationEntity {
  const ObservationModel({
    required super.readingId,
    required super.observationTitle,
    required super.observationDetail,
    required super.registrationDate,
    required super.connectionId,
    required super.previousReading,
    required super.currentReading,
    required super.sector,
    required super.account,
    required super.readingValue,
    required super.noveltyReadingTypeId,
    required super.noveltyTypeName,
    required super.noveltyTypeDescription,
    required super.address,
    required super.observations,
    required super.clientId,
    required super.clientName,
  });

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['citizenFirstName'] ?? '';
    final lastName = json['citizenLastName'] ?? '';

    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ObservationModel(
      readingId: json['readingId'] ?? 0,
      observationTitle: json['observationTitle'] ?? '',
      observationDetail: json['observationDetail'] ?? '',
      registrationDate: json['registrationDate'] ?? '',
      connectionId: json['connectionId'] ?? '',
      previousReading: parseDouble(json['previousReading']),
      currentReading: parseDouble(json['currentReading']),
      sector: json['sector'] ?? 0,
      account: json['account'] ?? 0,
      readingValue: parseDouble(json['readingValue']),
      noveltyReadingTypeId: json['noveltyReadingTypeId'] ?? 0,
      noveltyTypeName: json['noveltyTypeName'] ?? '',
      noveltyTypeDescription: json['noveltyTypeDescription'] ?? '',
      address: json['address'] ?? '',
      observations: json['observations'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: '$firstName $lastName'.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readingId': readingId,
      'observationTitle': observationTitle,
      'observationDetail': observationDetail,
      'registrationDate': formatFromIsoDate(registrationDate),
      'connectionId': connectionId,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'sector': sector,
      'account': account,
      'readingValue': readingValue,
      'noveltyReadingTypeId': noveltyReadingTypeId,
      'noveltyTypeName': noveltyTypeName,
      'noveltyTypeDescription': noveltyTypeDescription,
      'address': address,
      'observations': observations,
      'clientId': clientId,
      'clientName': clientName,
    };
  }
}
