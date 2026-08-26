// lib/features/scan/domain/usecases/get_reading_info.dart
import 'package:app_properties/features/reading/domain/entities/reading.dart';
import 'package:app_properties/features/reading/domain/repositories/reading_repository.dart';

class GetReadingInfo {
  final ReadingRepository repository;

  GetReadingInfo(this.repository);

  Future<List<Reading>> call(String cadastralKey) {
    return repository.getReadingInfo(cadastralKey);
  }
}
