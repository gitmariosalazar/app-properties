// lib/features/dashboard/domain/usecases/get_dashboard_stats.dart
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:dartz/dartz.dart';

class GetDashboardStats extends UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) {
    return repository.getDashboardStats();
  }
}
