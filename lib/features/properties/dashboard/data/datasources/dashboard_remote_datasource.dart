// lib/features/properties/dashboard/data/datasources/dashboard_remote_datasource.dart
//
// Capa de datos: Remote DataSource para el Dashboard de Predios.
//
// SOLID aplicado:
//   ISP  — contrato mínimo: un solo método por preocupación.
//   DIP  — la impl depende de http.Client y AuthLocalDataSource (abstracciones).
//   SRP  — solo parsea DTOs crudos; el mapeo a entidades lo hace el modelo.
//   OCP  — agregar un endpoint nuevo no modifica los existentes.

import 'dart:convert';
import 'package:app_properties/config/environments/environment.dart';
import 'package:app_properties/core/error/exception.dart';
import 'package:app_properties/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// DTO — existe solo en la capa de datos; el dominio nunca lo toca.
// ─────────────────────────────────────────────────────────────────────────────

/// Transporta la respuesta cruda de GET /connections/dashboard/advance.
/// Todos los campos son opcionales para tolerar evolución del backend (OCP).
class DashboardAdvanceDto {
  // resumen
  final int totalUniverso;
  final double pctProgresoTotal;
  final int actualizacionesHoy;

  // listas
  final List<Map<String, dynamic>> historico;
  final List<Map<String, dynamic>> distribucion;
  final List<Map<String, dynamic>> porZonas;
  final List<Map<String, dynamic>> distribucionTarifas;
  final List<Map<String, dynamic>> instalacionesRecientesCoords;
  final List<Map<String, dynamic>> curvaCrecimiento;

  // objetos simples
  final int conAlcantarillado;
  final int sinAlcantarillado;
  final double precisionPromedio;
  final int totalHabitantes;
  final int conMedidor;
  final int sinMedidor;
  final int activas;
  final int inactivas;

  const DashboardAdvanceDto({
    required this.totalUniverso,
    required this.pctProgresoTotal,
    required this.actualizacionesHoy,
    required this.historico,
    required this.distribucion,
    required this.porZonas,
    required this.distribucionTarifas,
    required this.instalacionesRecientesCoords,
    required this.curvaCrecimiento,
    required this.conAlcantarillado,
    required this.sinAlcantarillado,
    required this.precisionPromedio,
    required this.totalHabitantes,
    required this.conMedidor,
    required this.sinMedidor,
    required this.activas,
    required this.inactivas,
  });

  // ── Helpers de parseo tolerante ──────────────────────────────────────────────

  static int _int(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static double _double(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static List<Map<String, dynamic>> _list(dynamic v) {
    if (v is List) {
      return v.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  factory DashboardAdvanceDto.fromJson(Map<String, dynamic> json) {
    final resumen = json['resumen'] as Map<String, dynamic>? ?? {};
    final cobAlc =
        json['coberturaAlcantarillado'] as Map<String, dynamic>? ?? {};
    final gps = json['calidadGps'] as Map<String, dynamic>? ?? {};
    final pob = json['poblacionServida'] as Map<String, dynamic>? ?? {};
    final med = json['coberturaMedidores'] as Map<String, dynamic>? ?? {};
    final red = json['estadoRed'] as Map<String, dynamic>? ?? {};

    return DashboardAdvanceDto(
      // resumen
      totalUniverso: _int(resumen['total_universo']),
      pctProgresoTotal: _double(resumen['pct_progreso_total']),
      actualizacionesHoy: _int(resumen['actualizaciones_hoy']),
      // listas
      historico: _list(json['historico']),
      distribucion: _list(json['distribucion']),
      porZonas: _list(json['porZonas']),
      distribucionTarifas: _list(json['distribucionTarifas']),
      instalacionesRecientesCoords: _list(json['instalacionesRecientesCoords']),
      curvaCrecimiento: _list(json['curvaCrecimiento']),
      // cobertura alcantarillado
      conAlcantarillado: _int(cobAlc['con_alcantarillado']),
      sinAlcantarillado: _int(cobAlc['sin_alcantarillado']),
      // GPS
      precisionPromedio: _double(gps['precision_promedio']),
      // población
      totalHabitantes: _int(pob['total_habitantes']),
      // medidores
      conMedidor: _int(med['con_medidor']),
      sinMedidor: _int(med['sin_medidor']),
      // estado red
      activas: _int(red['activas']),
      inactivas: _int(red['inactivas']),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ABSTRACT CONTRACT
// ─────────────────────────────────────────────────────────────────────────────

abstract class DashboardRemoteDataSource {
  /// Obtiene las estadísticas avanzadas de predios.
  /// Lanza [NetworkException] si no hay red.
  /// Lanza [ServerException] si el servidor responde con error.
  Future<DashboardAdvanceDto> getDashboardAdvance();
}

// ─────────────────────────────────────────────────────────────────────────────
// CONCRETE IMPLEMENTATION
// ─────────────────────────────────────────────────────────────────────────────

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _base = Environment.apiUrl;

  DashboardRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401) {
      throw ServerException(
        'Sesión expirada. Por favor inicia sesión nuevamente.',
        401,
      );
    }
    if (response.statusCode >= 500) {
      throw ServerException(
        'Error interno del servidor (${response.statusCode})',
        response.statusCode,
      );
    }
  }

  // ── API call ──────────────────────────────────────────────────────────────

  @override
  Future<DashboardAdvanceDto> getDashboardAdvance() async {
    return guardNetwork(() async {
      final headers = await _headers();
      final uri = Uri.parse('$_base/connections/dashboard/advancement-stats');
      final response = await client.get(uri, headers: headers);

      _checkStatus(response);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final statusCode = body['status_code'] as int? ?? response.statusCode;

      if (statusCode >= 400) {
        final msgs = body['message'];
        final msg = msgs is List
            ? msgs.join(', ')
            : msgs?.toString() ?? 'Error al obtener dashboard';
        throw ServerException(msg, statusCode);
      }

      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return DashboardAdvanceDto.fromJson(data);
      }

      throw ServerException('Respuesta de dashboard inválida', statusCode);
    });
  }
}
