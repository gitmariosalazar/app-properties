// lib/features/properties/dashboard/presentation/cubit/dashboard_cubit.dart
//
// Cubit reactivo: se suscribe al stream de WatchDashboardStats y emite
// estados de UI de forma automática.
//
// Principios SOLID aplicados:
//   - SRP: el cubit sólo transforma estados; el polling vive en el repo.
//   - OCP: el método refresh() manual y el polling coexisten sin conflicto.
//   - LSP: hereda de Cubit<DashboardState> sin romper el contrato.
//   - DIP: depende de WatchDashboardStats y GetDashboardStats (abstracciones),
//          no de implementaciones concretas.

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_properties/core/usecases/usecase.dart';
import 'package:app_properties/features/properties/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'package:app_properties/features/properties/dashboard/domain/usecases/watch_dashboard_stats.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> with WidgetsBindingObserver {
  final GetDashboardStats _getDashboardStats;
  final WatchDashboardStats _watchDashboardStats;

  StreamSubscription? _subscription;

  DashboardCubit(
    this._getDashboardStats,
    this._watchDashboardStats,
  ) : super(DashboardInitial()) {
    // Registrar observer de ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
  }

  // ── Ciclo de vida ───────────────────────────────────────────────────────────

  /// Inicia el stream reactivo. Llamar al montar la pantalla.
  void startWatching() {
    if (_subscription != null) return; // idempotente
    _subscribeToStream();
  }

  void _subscribeToStream() {
    if (isClosed) return;

    // En el primer inicio emitimos Loading para mostrar skeleton/spinner
    if (state is DashboardInitial) {
      emit(DashboardLoading());
    }

    _subscription = _watchDashboardStats().listen(
      (stats) {
        if (!isClosed) emit(DashboardLoaded(stats));
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(DashboardError(error.toString()));
        }
      },
      cancelOnError: false, // sigue intentando en el próximo tick de polling
    );
  }

  // ── Refresh manual (pull-to-refresh) ───────────────────────────────────────

  Future<void> refresh() async {
    if (isClosed) return;
    // Hace un fetch puntual inmediato sin interrumpir el polling background.
    final result = await _getDashboardStats(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (stats) => emit(DashboardLoaded(stats)),
    );
  }

  // ── AppLifecycle: pausa polling en background, reanuda en foreground ────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // La app volvió al frente: reanudar suscripción si estaba pausada.
        if (_subscription == null && !isClosed) {
          _subscribeToStream();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Cancelar polling mientras la app está en background para ahorrar
        // batería y ancho de banda.
        _cancelSubscription();
        break;
    }
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ── Limpieza ────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSubscription();
    return super.close();
  }
}
