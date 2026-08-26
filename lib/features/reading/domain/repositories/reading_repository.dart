// lib/features/scan/domain/repositories/reading_repository.dart
import 'package:app_properties/features/reading/data/model/create_reading_request.dart';
import 'package:app_properties/features/reading/data/model/update_reading_request.dart';
import 'package:app_properties/features/reading/domain/entities/reading.dart';
import 'package:app_properties/features/reading/domain/entities/reading_result.dart';

abstract class ReadingRepository {
  Future<List<Reading>> getReadingInfo(String cadastralKey);
  Future<List<Reading>> findBasicReading(String catastralCode);
  Future<ReadingResult> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  );
  Future<ReadingResult> createReading(CreateReadingRequest request);
}
