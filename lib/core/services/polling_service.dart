// lib/core/services/polling_service.dart
//
// Propósito: Servicio genérico de polling basado en Streams.
// Principios aplicados:
//   - SRP: sólo gestiona el ciclo de polling (nada de lógica de negocio).
//   - OCP: extendible por tipo <T> sin modificar la clase.
//   - DIP: recibe una función fetcher como dependencia inyectada.
//   - ISP: expone sólo los contratos necesarios (stream / dispose).

import 'dart:async';

/// Contrato abstracto que permite mockear el servicio en tests.
abstract class PollingService<T> {
  /// Stream que emite el último valor obtenido o el error como [PollingError<T>].
  Stream<T> get stream;

  /// Inicia el ciclo de polling.
  void start();

  /// Detiene el ciclo de polling y libera recursos.
  void dispose();
}

/// Implementación concreta de [PollingService] basada en [Timer.periodic].
///
/// Estrategia:
///  1. Emite inmediatamente al suscribirse (eager fetch).
///  2. Repite cada [interval].
///  3. En caso de error llama a [onError] y sigue intentando; los errores
///     no rompen el stream (resiliente por diseño).
class PeriodicPollingService<T> implements PollingService<T> {
  final Future<T> Function() _fetcher;
  final Duration interval;
  final void Function(Object error, StackTrace st)? onError;

  final _controller = StreamController<T>.broadcast();
  Timer? _timer;
  bool _disposed = false;

  PeriodicPollingService({
    required Future<T> Function() fetcher,
    required this.interval,
    this.onError,
  }) : _fetcher = fetcher;

  @override
  Stream<T> get stream => _controller.stream;

  @override
  void start() {
    if (_disposed) return;
    _fetch(); // eager: primer dato inmediato
    _timer = Timer.periodic(interval, (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_disposed) return;
    try {
      final result = await _fetcher();
      if (!_disposed && !_controller.isClosed) {
        _controller.add(result);
      }
    } catch (e, st) {
      onError?.call(e, st);
      if (!_disposed && !_controller.isClosed) {
        _controller.addError(e, st);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }
}
