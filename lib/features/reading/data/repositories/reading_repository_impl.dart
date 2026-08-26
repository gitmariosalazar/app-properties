// lib/features/scan/data/repositories/reading_repository_impl.dart
import 'package:app_properties/features/reading/data/datasources/remote_reading_data_source.dart';
import 'package:app_properties/features/reading/data/mappers/reading_mapper.dart';
import 'package:app_properties/features/reading/data/model/create_reading_request.dart';
import 'package:app_properties/features/reading/data/model/reading_basic_info_response.dart';
import 'package:app_properties/features/reading/data/model/reading_response.dart';
import 'package:app_properties/features/reading/data/model/update_reading_request.dart';
import 'package:app_properties/features/reading/domain/entities/reading.dart';
import 'package:app_properties/features/reading/domain/entities/reading_basic_info.dart';
import 'package:app_properties/features/reading/domain/entities/reading_result.dart';
import 'package:app_properties/features/reading/domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final RemoteReadingDataSource dataSource;

  ReadingRepositoryImpl(this.dataSource);

  @override
  Future<List<Reading>> getReadingInfo(String cadastralKey) async {
    final dto = await dataSource.getReadingInfo(cadastralKey);
    return dto.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Reading>> findBasicReading(String catastralCode) async {
    final dtos = await dataSource.findBasicReading(catastralCode);
    return dtos.map((dto) => _mapBasicInfoToEntity(dto)).toList();
  }

  @override
  Future<ReadingResult> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  ) async {
    final dto = await dataSource.updateCurrentReading(readingId, request);
    return _mapResponseToEntity(dto);
  }

  @override
  Future<ReadingResult> createReading(CreateReadingRequest request) async {
    final dto = await dataSource.createReading(request);
    return _mapResponseToEntity(dto);
  }

  // Mappers (could be moved to separate mapper files)
  Reading _mapBasicInfoToEntity(ReadingBasicInfoResponse dto) {
    return Reading(
      readingId: dto.readingId,
      previousReadingDate: dto.previousReadingDate != null
          ? DateTime.tryParse(dto.previousReadingDate!)
          : null,
      cadastralKey: dto.cadastralKey,
      cardId: dto.cardId,
      clientName: dto.clientName,
      address: dto.address,
      previousReading: dto.previousReading?.toString(),
      currentReading: dto.currentReading?.toString(),
      sector: dto.sector,
      account: dto.account,
      readingValue: dto.readingValue?.toString(),
      averageConsumption: dto.averageConsumption?.toString(),
      meterNumber: dto.meterNumber,
      rateId: dto.rateId,
      rateName: dto.rateName,
    );
  }

  ReadingResult _mapResponseToEntity(ReadingResponse dto) {
    return ReadingResult(
      readingId: dto.readingId,
      connectionId: dto.connectionId,
      readingDate: dto.readingDate != null
          ? DateTime.parse(dto.readingDate!)
          : null,
      readingTime: dto.readingTime,
      sector: dto.sector,
      account: dto.account,
      cadastralKey: dto.cadastralKey,
      readingValue: dto.readingValue,
      sewerRate: dto.sewerRate,
      previousReading: dto.previousReading,
      currentReading: dto.currentReading,
      rentalIncomeCode: dto.rentalIncomeCode,
      novelty: dto.novelty,
      incomeCode: dto.incomeCode,
    );
  }
}
