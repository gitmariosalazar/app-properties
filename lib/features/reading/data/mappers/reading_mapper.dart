// lib/features/scan/data/mappers/reading_info_mapper.dart
import 'package:app_properties/features/reading/domain/entities/reading.dart';
import 'package:app_properties/features/reading/data/model/reading_info_response.dart'
    as dto;

extension ReadingInfoResponseX on dto.ReadingInfoResponse {
  Reading toEntity() {
    return Reading(
      readingId: readingId,
      previousReadingDate: previousReadingDate != null
          ? DateTime.tryParse(previousReadingDate!)
          : null,
      readingTime: readingTime != null ? _parseTime(readingTime!) : null,
      cadastralKey: cadastralKey,
      cardId: cardId,
      clientName: clientName,
      phones:
          clientPhones
              ?.where((p) => p.numero != null)
              .map((p) => Phone(p.numero!))
              .toList() ??
          [],
      emails:
          clientEmails
              ?.where((e) => e.email != null)
              .map((e) => Email(e.email!))
              .toList() ??
          [],
      address: address,
      // Mapping string to string as per updated Entity definition, or keep it raw?
      // Entity definition in Step 255 has String? previousReading.
      previousReading: previousReading,
      currentReading: currentReading,
      sector: sector,
      account: account,
      readingValue: readingValue,
      averageConsumption: averageConsumption,
      meterNumber: meterNumber,
      rateId: rateId,
      rateName: rateName,
      hasCurrentReading: hasCurrentReading,
      monthReading: monthReading,
      startDatePeriod: startDatePeriod != null
          ? DateTime.tryParse(startDatePeriod!)
          : null,
      endDatePeriod: endDatePeriod != null
          ? DateTime.tryParse(endDatePeriod!)
          : null,
      connectionStateId: connectionStateId,
      connectionStateName: connectionStateName,
      connectionStateDescription: connectionStateDescription,
      permitReading: permitReading,
      connectionLocation: ConnectionLocation(
        lat: connectionLocation?.lat,
        lng: connectionLocation?.lng,
      ),
    );
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return null;
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 0,
        parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
      );
    } catch (e) {
      return null;
    }
  }
}
