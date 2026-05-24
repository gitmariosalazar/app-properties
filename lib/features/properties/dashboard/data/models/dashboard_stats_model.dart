// lib/features/properties/dashboard/data/models/dashboard_stats_model.dart
//
// Capa de datos: modelos de mapeo (DTO → Entidad de dominio).
//
// SOLID aplicado:
//   SRP — cada clase modelo mapea exactamente una entidad de dominio.
//   OCP — agregar un nuevo campo solo toca el modelo correspondiente.
//   DIP — el dominio nunca importa este archivo; la dependencia va de data → domain.

import 'package:app_properties/features/properties/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELO RAÍZ
// Convierte el DTO crudo en la entidad de dominio.
// ─────────────────────────────────────────────────────────────────────────────
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.resumen,
    required super.historico,
    required super.distribucion,
    required super.porZonas,
    required super.distribucionTarifas,
    required super.coberturaAlcantarillado,
    required super.calidadGps,
    required super.instalacionesRecientesCoords,
    required super.curvaCrecimiento,
    required super.poblacionServida,
    required super.coberturaMedidores,
    required super.estadoRed,
  });

  /// Convierte el [DashboardAdvanceDto] en la entidad [DashboardStats].
  factory DashboardStatsModel.fromDto(DashboardAdvanceDto dto) {
    return DashboardStatsModel(
      resumen: DashboardResumenModel.fromDto(dto),
      historico: dto.historico
          .map(DashboardHistoricoModel.fromJson)
          .toList(),
      distribucion: dto.distribucion
          .map(DashboardDistribucionModel.fromJson)
          .toList(),
      porZonas: dto.porZonas
          .map(DashboardPorZonaModel.fromJson)
          .toList(),
      distribucionTarifas: dto.distribucionTarifas
          .map(DashboardDistribucionTarifaModel.fromJson)
          .toList(),
      coberturaAlcantarillado: DashboardCoberturaAlcantarilladoModel.fromDto(dto),
      calidadGps: DashboardCalidadGpsModel.fromDto(dto),
      instalacionesRecientesCoords: dto.instalacionesRecientesCoords
          .map(DashboardInstalacionCoordModel.fromJson)
          .toList(),
      curvaCrecimiento: dto.curvaCrecimiento
          .map(DashboardCurvaCrecimientoModel.fromJson)
          .toList(),
      poblacionServida: DashboardPoblacionServidaModel.fromDto(dto),
      coberturaMedidores: DashboardCoberturaMedidoresModel.fromDto(dto),
      estadoRed: DashboardEstadoRedModel.fromDto(dto),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUB-MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class DashboardResumenModel extends DashboardResumen {
  const DashboardResumenModel({
    required super.totalUniverso,
    required super.pctProgresoTotal,
    required super.actualizacionesHoy,
  });

  factory DashboardResumenModel.fromDto(DashboardAdvanceDto dto) =>
      DashboardResumenModel(
        totalUniverso: dto.totalUniverso,
        pctProgresoTotal: dto.pctProgresoTotal,
        actualizacionesHoy: dto.actualizacionesHoy,
      );
}

// ── historico ────────────────────────────────────────────────────────────────

class DashboardHistoricoModel extends DashboardHistorico {
  const DashboardHistoricoModel({
    required super.fecha,
    required super.registrosCompletados,
  });

  factory DashboardHistoricoModel.fromJson(Map<String, dynamic> json) =>
      DashboardHistoricoModel(
        fecha: json['fecha']?.toString() ?? '',
        registrosCompletados: _int(json['registros_completados']),
      );
}

// ── distribucion ─────────────────────────────────────────────────────────────

class DashboardDistribucionModel extends DashboardDistribucion {
  const DashboardDistribucionModel({
    required super.categoria,
    required super.cantidad,
  });

  factory DashboardDistribucionModel.fromJson(Map<String, dynamic> json) =>
      DashboardDistribucionModel(
        categoria: json['categoria']?.toString() ?? '',
        cantidad: _int(json['cantidad']),
      );
}

// ── porZonas ─────────────────────────────────────────────────────────────────

class DashboardPorZonaModel extends DashboardPorZona {
  const DashboardPorZonaModel({
    required super.zonaId,
    required super.total,
    required super.completados,
    required super.pendientes,
  });

  factory DashboardPorZonaModel.fromJson(Map<String, dynamic> json) =>
      DashboardPorZonaModel(
        zonaId: _int(json['zona_id']),
        total: _int(json['total']),
        completados: _int(json['completados']),
        pendientes: _int(json['pendientes']),
      );
}

// ── distribucionTarifas ──────────────────────────────────────────────────────

class DashboardDistribucionTarifaModel extends DashboardDistribucionTarifa {
  const DashboardDistribucionTarifaModel({
    required super.tarifa,
    required super.cantidad,
  });

  factory DashboardDistribucionTarifaModel.fromJson(Map<String, dynamic> json) =>
      DashboardDistribucionTarifaModel(
        tarifa: json['tarifa']?.toString() ?? '',
        cantidad: _int(json['cantidad']),
      );
}

// ── coberturaAlcantarillado ──────────────────────────────────────────────────

class DashboardCoberturaAlcantarilladoModel
    extends DashboardCoberturaAlcantarillado {
  const DashboardCoberturaAlcantarilladoModel({
    required super.conAlcantarillado,
    required super.sinAlcantarillado,
  });

  factory DashboardCoberturaAlcantarilladoModel.fromDto(
    DashboardAdvanceDto dto,
  ) =>
      DashboardCoberturaAlcantarilladoModel(
        conAlcantarillado: dto.conAlcantarillado,
        sinAlcantarillado: dto.sinAlcantarillado,
      );
}

// ── calidadGps ───────────────────────────────────────────────────────────────

class DashboardCalidadGpsModel extends DashboardCalidadGps {
  const DashboardCalidadGpsModel({required super.precisionPromedio});

  factory DashboardCalidadGpsModel.fromDto(DashboardAdvanceDto dto) =>
      DashboardCalidadGpsModel(precisionPromedio: dto.precisionPromedio);
}

// ── instalacionesRecientesCoords ─────────────────────────────────────────────

class DashboardInstalacionCoordModel extends DashboardInstalacionCoord {
  const DashboardInstalacionCoordModel({
    required super.coordenadas,
    required super.fecha,
  });

  factory DashboardInstalacionCoordModel.fromJson(Map<String, dynamic> json) =>
      DashboardInstalacionCoordModel(
        coordenadas: json['coordenadas']?.toString() ?? '',
        fecha: json['fecha']?.toString() ?? '',
      );
}

// ── curvaCrecimiento ─────────────────────────────────────────────────────────

class DashboardCurvaCrecimientoModel extends DashboardCurvaCrecimiento {
  const DashboardCurvaCrecimientoModel({
    required super.mes,
    required super.nuevasAcometidas,
  });

  factory DashboardCurvaCrecimientoModel.fromJson(Map<String, dynamic> json) =>
      DashboardCurvaCrecimientoModel(
        mes: json['mes']?.toString() ?? '',
        nuevasAcometidas: _int(json['nuevas_acometidas']),
      );
}

// ── poblacionServida ─────────────────────────────────────────────────────────

class DashboardPoblacionServidaModel extends DashboardPoblacionServida {
  const DashboardPoblacionServidaModel({required super.totalHabitantes});

  factory DashboardPoblacionServidaModel.fromDto(DashboardAdvanceDto dto) =>
      DashboardPoblacionServidaModel(totalHabitantes: dto.totalHabitantes);
}

// ── coberturaMedidores ───────────────────────────────────────────────────────

class DashboardCoberturaMedidoresModel extends DashboardCoberturaMedidores {
  const DashboardCoberturaMedidoresModel({
    required super.conMedidor,
    required super.sinMedidor,
  });

  factory DashboardCoberturaMedidoresModel.fromDto(DashboardAdvanceDto dto) =>
      DashboardCoberturaMedidoresModel(
        conMedidor: dto.conMedidor,
        sinMedidor: dto.sinMedidor,
      );
}

// ── estadoRed ────────────────────────────────────────────────────────────────

class DashboardEstadoRedModel extends DashboardEstadoRed {
  const DashboardEstadoRedModel({
    required super.activas,
    required super.inactivas,
  });

  factory DashboardEstadoRedModel.fromDto(DashboardAdvanceDto dto) =>
      DashboardEstadoRedModel(
        activas: dto.activas,
        inactivas: dto.inactivas,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER PRIVADO de parseo (módulo-local)
// ─────────────────────────────────────────────────────────────────────────────
int _int(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}
