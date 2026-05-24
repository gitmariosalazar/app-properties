// lib/features/properties/dashboard/data/repositories/dashboard_repository_impl.dart
//
// Implementación concreta de [DashboardRepository].
//
// Estrategia de refresco: Polling periódico (60 s) con carga inicial inmediata.
// No usa WebSocket porque este proyecto no tiene un servicio WS configurado;
// si se añade en el futuro, basta con agregar el listener aquí (OCP).
//
// SOLID aplicado:
//   LSP — implementa completamente el contrato [DashboardRepository].
//   DIP — depende de [DashboardRemoteDataSource] (abstracción), nunca de la impl.
//   OCP — la estrategia de polling se puede sustituir sin cambiar el contrato.
//   SRP — solo responsable de obtener y emitir [DashboardStats].

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/core/error/failure.dart';
import 'package:app_properties/features/properties/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:app_properties/features/properties/dashboard/data/models/dashboard_stats_model.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  /// Intervalo de polling de respaldo. 60 s es conservador para datos
  /// catastrales que no cambian con alta frecuencia.
  final Duration pollingInterval;

  Timer? _pollingTimer;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    this.pollingInterval = const Duration(seconds: 60),
  });

  // ── Fetch interno ──────────────────────────────────────────────────────────

  Future<DashboardStats> _fetchStats() async {
    final dto = await remoteDataSource.getDashboardAdvance();
    return DashboardStatsModel.fromDto(dto);
  }

  // ── DashboardRepository ────────────────────────────────────────────────────

  /// Fetch puntual: una sola llamada al backend.
  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      return Right(await _fetchStats());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  /// Stream reactivo con:
  ///  1. Carga inicial inmediata.
  ///  2. Polling periódico cada [pollingInterval].
  ///
  /// El controller es de tipo `broadcast` para que varios listeners
  /// (e.g. cubit + tests) puedan suscribirse sin error.
  @override
  Stream<DashboardStats> watchDashboardStats() {
    late StreamController<DashboardStats> controller;

    Future<void> loadAndEmit() async {
      if (controller.isClosed) return;
      try {
        final stats = await _fetchStats();
        if (!controller.isClosed) {
          controller.add(stats);
        }
      } on NetworkException catch (e) {
        debugPrint('[Dashboard] Sin red: ${e.message}');
        if (!controller.isClosed) {
          controller.addError(NetworkFailure(message: e.message));
        }
      } on ServerException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerFailure(message: e.message, code: e.code));
        }
      } catch (e) {
        debugPrint('[Dashboard] Error inesperado: $e');
        if (!controller.isClosed) {
          controller.addError(ServerFailure(message: 'Error inesperado: $e'));
        }
      }
    }

    controller = StreamController<DashboardStats>.broadcast(
      onListen: () {
        // ── 1. Carga inicial inmediata ────────────────────────────────────────
        loadAndEmit();
        // ── 2. Polling periódico ──────────────────────────────────────────────
        _pollingTimer = Timer.periodic(pollingInterval, (_) => loadAndEmit());
      },
      onCancel: () {
        _stopPolling();
        controller.close();
      },
    );

    return controller.stream;
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Libera recursos.
  void dispose() {
    _stopPolling();
  }
}
