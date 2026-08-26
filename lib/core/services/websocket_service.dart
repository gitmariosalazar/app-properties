// lib/core/services/websocket_service.dart
//
// Servicio WebSocket usando Socket.IO (socket_io_client).
// Resiliente: los errores de conexión se loguean pero NUNCA crashean la app.
// SRP: solo gestiona la conexión y suscripción a eventos.
// DIP: las capas superiores dependen de la interfaz abstracta.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// ── Nombres de eventos — deben coincidir exactamente con el backend ──────────
class WsEvents {
  static const readingUpdated = 'reading:updated';
  static const auditUpdated = 'audit:updated';
}

// ── Payloads tipados ──────────────────────────────────────────────────────────
class ReadingUpdatedPayload {
  final int sectorId;
  final String month;
  final String type;

  const ReadingUpdatedPayload({
    required this.sectorId,
    required this.month,
    required this.type,
  });

  factory ReadingUpdatedPayload.fromMap(Map<dynamic, dynamic> map) {
    return ReadingUpdatedPayload(
      sectorId: (map['sectorId'] as num?)?.toInt() ?? 0,
      month: map['month']?.toString() ?? '',
      type: map['type']?.toString() ?? 'updated',
    );
  }
}

class AuditUpdatedPayload {
  final int sectorId;
  final String month;
  final String type;

  const AuditUpdatedPayload({
    required this.sectorId,
    required this.month,
    required this.type,
  });

  factory AuditUpdatedPayload.fromMap(Map<dynamic, dynamic> map) {
    return AuditUpdatedPayload(
      sectorId: (map['sectorId'] as num?)?.toInt() ?? 0,
      month: map['month']?.toString() ?? '',
      type: map['type']?.toString() ?? 'progress_changed',
    );
  }
}

// ── Interfaz abstracta (DIP) ────────────────────────────────────────────────
abstract class WebSocketService {
  Stream<ReadingUpdatedPayload> get onReadingUpdated;
  Stream<AuditUpdatedPayload> get onAuditUpdated;

  /// true = conectado, false = desconectado o reconectando
  ValueNotifier<bool> get isConnected;

  /// true cuando se agotaron todos los intentos de reconexión
  ValueNotifier<bool> get isReconnectExhausted;

  void connect(String baseUrl, {String? token});
  void disconnect();

  /// Libera todos los recursos (streams + socket). Llamar al cerrar la sesión.
  void dispose();
}

// ── Implementación resiliente con Socket.IO ────────────────────────────────
class SocketIOWebSocketService implements WebSocketService {
  io.Socket? _socket;

  // broadcast + onError handler: los errores no crashean la app
  final _readingController = StreamController<ReadingUpdatedPayload>.broadcast();
  final _auditController = StreamController<AuditUpdatedPayload>.broadcast();

  @override
  final isConnected = ValueNotifier<bool>(false);

  @override
  final isReconnectExhausted = ValueNotifier<bool>(false);

  @override
  Stream<ReadingUpdatedPayload> get onReadingUpdated => _readingController.stream;

  @override
  Stream<AuditUpdatedPayload> get onAuditUpdated => _auditController.stream;

  @override
  void connect(String baseUrl, {String? token}) {
    // Idempotente: no reconecta si ya está activo
    if (_socket?.connected == true) return;

    // Resetear estado de reconexión agotada al intentar nueva conexión
    isReconnectExhausted.value = false;

    try {
      _socket = io.io(
        '$baseUrl/realtime',
        io.OptionBuilder()
            // 'websocket' directo en apps nativas (sin CORS, sin polling innecesario)
            .setTransports(['websocket'])
            .enableReconnection()
            .setReconnectionDelay(3000)       // 3s entre intentos
            .setReconnectionDelayMax(30000)   // máximo 30s de espera entre intentos
            .setReconnectionAttempts(10)      // 10 intentos antes de rendirse
            // ✅ CORRECTO: el token va en `auth`, que NestJS lee desde
            // client.handshake.auth.token en handleConnection()
            // ❌ INCORRECTO: setExtraHeaders({'Authorization': 'Bearer $token'})
            //    porque eso va a handshake.headers y el gateway no lo lee ahí.
            .setAuth(token != null ? {'token': token} : {})
            .build(),
      );

      _socket!
        ..onConnect((_) {
          isConnected.value = true;
          isReconnectExhausted.value = false;
          debugPrint('[WS] ✅ Conectado a $baseUrl/realtime');
        })
        ..onDisconnect((_) {
          isConnected.value = false;
          debugPrint('[WS] ❌ Desconectado');
        })
        ..onReconnect((_) {
          debugPrint('[WS] 🔄 Reconectado exitosamente');
        })
        ..onReconnectFailed((_) {
          // Se agotaron todos los intentos — notificar a la UI para mostrar alerta
          isConnected.value = false;
          isReconnectExhausted.value = true;
          debugPrint('[WS] 🚫 Reconexión agotada. La UI debe mostrar aviso al usuario.');
        })
        ..onConnectError((err) {
          isConnected.value = false;
          debugPrint('[WS] ⚠️ No se pudo conectar: $err');
        })
        ..onError((err) {
          debugPrint('[WS] ⚠️ Error de socket: $err');
        })
        ..on(WsEvents.readingUpdated, (data) {
          try {
            if (!_readingController.isClosed && data != null) {
              _readingController.add(
                ReadingUpdatedPayload.fromMap(data as Map<dynamic, dynamic>),
              );
            }
          } catch (e) {
            debugPrint('[WS] Error parseando reading:updated: $e');
          }
        })
        ..on(WsEvents.auditUpdated, (data) {
          try {
            if (!_auditController.isClosed && data != null) {
              _auditController.add(
                AuditUpdatedPayload.fromMap(data as Map<dynamic, dynamic>),
              );
            }
          } catch (e) {
            debugPrint('[WS] Error parseando audit:updated: $e');
          }
        });
    } catch (e) {
      debugPrint('[WS] ⚠️ No se pudo inicializar el socket: $e');
    }
  }

  @override
  void disconnect() {
    try {
      if (_socket != null) {
        // Desactivar reconexión automática ANTES de desconectar para evitar loops zombie
        _socket!.io.options?['reconnection'] = false;
        _socket!.disconnect();
        _socket!.dispose();
      }
    } catch (_) {}
    _socket = null;
    isConnected.value = false;
  }

  @override
  void dispose() {
    disconnect();
    if (!_readingController.isClosed) _readingController.close();
    if (!_auditController.isClosed) _auditController.close();
    isConnected.dispose();
    isReconnectExhausted.dispose();
  }
}
