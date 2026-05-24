// lib/features/properties/dashboard/domain/entities/dashboard_stats.dart
//
// Clean Architecture: Domain entity — pure Dart, zero external dependencies.
// SOLID: SRP — each inner class models exactly one sub-concept of the response.

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROOT ENTITY
// ─────────────────────────────────────────────────────────────────────────────
class DashboardStats extends Equatable {
  final DashboardResumen resumen;
  final List<DashboardHistorico> historico;
  final List<DashboardDistribucion> distribucion;
  final List<DashboardPorZona> porZonas;
  final List<DashboardDistribucionTarifa> distribucionTarifas;
  final DashboardCoberturaAlcantarillado coberturaAlcantarillado;
  final DashboardCalidadGps calidadGps;
  final List<DashboardInstalacionCoord> instalacionesRecientesCoords;
  final List<DashboardCurvaCrecimiento> curvaCrecimiento;
  final DashboardPoblacionServida poblacionServida;
  final DashboardCoberturaMedidores coberturaMedidores;
  final DashboardEstadoRed estadoRed;

  const DashboardStats({
    required this.resumen,
    required this.historico,
    required this.distribucion,
    required this.porZonas,
    required this.distribucionTarifas,
    required this.coberturaAlcantarillado,
    required this.calidadGps,
    required this.instalacionesRecientesCoords,
    required this.curvaCrecimiento,
    required this.poblacionServida,
    required this.coberturaMedidores,
    required this.estadoRed,
  });

  @override
  List<Object?> get props => [
        resumen,
        historico,
        distribucion,
        porZonas,
        distribucionTarifas,
        coberturaAlcantarillado,
        calidadGps,
        instalacionesRecientesCoords,
        curvaCrecimiento,
        poblacionServida,
        coberturaMedidores,
        estadoRed,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// resumen
// ─────────────────────────────────────────────────────────────────────────────
class DashboardResumen extends Equatable {
  /// Total de predios en el universo catastral.
  final int totalUniverso;

  /// Porcentaje de progreso — puede venir como string o número desde la API.
  final double pctProgresoTotal;

  /// Actualizaciones realizadas hoy.
  final int actualizacionesHoy;

  const DashboardResumen({
    required this.totalUniverso,
    required this.pctProgresoTotal,
    required this.actualizacionesHoy,
  });

  @override
  List<Object?> get props => [totalUniverso, pctProgresoTotal, actualizacionesHoy];
}

// ─────────────────────────────────────────────────────────────────────────────
// historico
// ─────────────────────────────────────────────────────────────────────────────
class DashboardHistorico extends Equatable {
  final String fecha;
  final int registrosCompletados;

  const DashboardHistorico({
    required this.fecha,
    required this.registrosCompletados,
  });

  @override
  List<Object?> get props => [fecha, registrosCompletados];
}

// ─────────────────────────────────────────────────────────────────────────────
// distribucion
// ─────────────────────────────────────────────────────────────────────────────
class DashboardDistribucion extends Equatable {
  final String categoria;
  final int cantidad;

  const DashboardDistribucion({
    required this.categoria,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [categoria, cantidad];
}

// ─────────────────────────────────────────────────────────────────────────────
// porZonas
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPorZona extends Equatable {
  final int zonaId;
  final int total;
  final int completados;
  final int pendientes;

  const DashboardPorZona({
    required this.zonaId,
    required this.total,
    required this.completados,
    required this.pendientes,
  });

  @override
  List<Object?> get props => [zonaId, total, completados, pendientes];
}

// ─────────────────────────────────────────────────────────────────────────────
// distribucionTarifas
// ─────────────────────────────────────────────────────────────────────────────
class DashboardDistribucionTarifa extends Equatable {
  final String tarifa;
  final int cantidad;

  const DashboardDistribucionTarifa({
    required this.tarifa,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [tarifa, cantidad];
}

// ─────────────────────────────────────────────────────────────────────────────
// coberturaAlcantarillado
// ─────────────────────────────────────────────────────────────────────────────
class DashboardCoberturaAlcantarillado extends Equatable {
  final int conAlcantarillado;
  final int sinAlcantarillado;

  const DashboardCoberturaAlcantarillado({
    required this.conAlcantarillado,
    required this.sinAlcantarillado,
  });

  @override
  List<Object?> get props => [conAlcantarillado, sinAlcantarillado];
}

// ─────────────────────────────────────────────────────────────────────────────
// calidadGps
// ─────────────────────────────────────────────────────────────────────────────
class DashboardCalidadGps extends Equatable {
  final double precisionPromedio;

  const DashboardCalidadGps({required this.precisionPromedio});

  @override
  List<Object?> get props => [precisionPromedio];
}

// ─────────────────────────────────────────────────────────────────────────────
// instalacionesRecientesCoords
// ─────────────────────────────────────────────────────────────────────────────
class DashboardInstalacionCoord extends Equatable {
  final String coordenadas;
  final String fecha;

  const DashboardInstalacionCoord({
    required this.coordenadas,
    required this.fecha,
  });

  @override
  List<Object?> get props => [coordenadas, fecha];
}

// ─────────────────────────────────────────────────────────────────────────────
// curvaCrecimiento
// ─────────────────────────────────────────────────────────────────────────────
class DashboardCurvaCrecimiento extends Equatable {
  final String mes;
  final int nuevasAcometidas;

  const DashboardCurvaCrecimiento({
    required this.mes,
    required this.nuevasAcometidas,
  });

  @override
  List<Object?> get props => [mes, nuevasAcometidas];
}

// ─────────────────────────────────────────────────────────────────────────────
// poblacionServida
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPoblacionServida extends Equatable {
  final int totalHabitantes;

  const DashboardPoblacionServida({required this.totalHabitantes});

  @override
  List<Object?> get props => [totalHabitantes];
}

// ─────────────────────────────────────────────────────────────────────────────
// coberturaMedidores
// ─────────────────────────────────────────────────────────────────────────────
class DashboardCoberturaMedidores extends Equatable {
  final int conMedidor;
  final int sinMedidor;

  const DashboardCoberturaMedidores({
    required this.conMedidor,
    required this.sinMedidor,
  });

  @override
  List<Object?> get props => [conMedidor, sinMedidor];
}

// ─────────────────────────────────────────────────────────────────────────────
// estadoRed
// ─────────────────────────────────────────────────────────────────────────────
class DashboardEstadoRed extends Equatable {
  final int activas;
  final int inactivas;

  const DashboardEstadoRed({
    required this.activas,
    required this.inactivas,
  });

  @override
  List<Object?> get props => [activas, inactivas];
}
