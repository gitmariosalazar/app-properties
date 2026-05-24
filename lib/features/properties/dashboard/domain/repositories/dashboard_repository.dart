// lib/features/dashboard/domain/repositories/dashboard_repository.dart
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';
import 'package:dartz/dartz.dart';

abstract class DashboardRepository {
  /// Fetch puntual — se conserva para compatibilidad hacia atrás (OCP).
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  /// Stream reactivo: emite cada vez que hay datos nuevos.
  /// Los errores deben propagarse como eventos de error del stream.
  Stream<DashboardStats> watchDashboardStats();
}
