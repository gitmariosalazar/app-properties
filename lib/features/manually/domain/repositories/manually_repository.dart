import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/failure.dart';

abstract class ManuallyRepository {
  Future<Either<Failure, Map<String, dynamic>>> fetchReading(
    String connectionId,
  );
}
