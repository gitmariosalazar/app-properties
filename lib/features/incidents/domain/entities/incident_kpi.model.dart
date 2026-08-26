class IncidentDashboardKpiResponse {
  final KpisGenerales kpisGenerales;
  final List<DistribucionEstado> porEstado;
  final List<DistribucionCategoria> porCategoria;
  final List<DistribucionOrigen> porOrigenReporte;
  final List<DistribucionPrioridad> porPrioridad;
  final List<TendenciaDiaria> tendenciaUltimos30Dias;
  final List<IncidenteCritico> atencionInmediata;

  IncidentDashboardKpiResponse({
    required this.kpisGenerales,
    required this.porEstado,
    required this.porCategoria,
    required this.porOrigenReporte,
    required this.porPrioridad,
    required this.tendenciaUltimos30Dias,
    required this.atencionInmediata,
  });

  factory IncidentDashboardKpiResponse.fromJson(Map<String, dynamic> json) {
    return IncidentDashboardKpiResponse(
      kpisGenerales: KpisGenerales.fromJson(json['kpis_generales'] ?? {}),
      porEstado: (json['por_estado'] as List<dynamic>?)
              ?.map((e) => DistribucionEstado.fromJson(e))
              .toList() ??
          [],
      porCategoria: (json['por_categoria'] as List<dynamic>?)
              ?.map((e) => DistribucionCategoria.fromJson(e))
              .toList() ??
          [],
      porOrigenReporte: (json['por_origen_reporte'] as List<dynamic>?)
              ?.map((e) => DistribucionOrigen.fromJson(e))
              .toList() ??
          [],
      porPrioridad: (json['por_prioridad'] as List<dynamic>?)
              ?.map((e) => DistribucionPrioridad.fromJson(e))
              .toList() ??
          [],
      tendenciaUltimos30Dias: (json['tendencia_ultimos_30_dias'] as List<dynamic>?)
              ?.map((e) => TendenciaDiaria.fromJson(e))
              .toList() ??
          [],
      atencionInmediata: (json['atencion_inmediata'] as List<dynamic>?)
              ?.map((e) => IncidenteCritico.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class KpisGenerales {
  final int totalIncidentes;
  final int totalPendientes;
  final int totalResueltos;
  final int totalCriticosActivos;
  final double costoReparacionAcumulado;
  final double tiempoPromedioResolucionDias;

  KpisGenerales({
    required this.totalIncidentes,
    required this.totalPendientes,
    required this.totalResueltos,
    required this.totalCriticosActivos,
    required this.costoReparacionAcumulado,
    required this.tiempoPromedioResolucionDias,
  });

  factory KpisGenerales.fromJson(Map<String, dynamic> json) {
    return KpisGenerales(
      totalIncidentes: json['total_incidentes'] ?? 0,
      totalPendientes: json['total_pendientes'] ?? 0,
      totalResueltos: json['total_resueltos'] ?? 0,
      totalCriticosActivos: json['total_criticos_activos'] ?? 0,
      costoReparacionAcumulado: (json['costo_reparacion_acumulado'] ?? 0).toDouble(),
      tiempoPromedioResolucionDias: (json['tiempo_promedio_resolucion_dias'] ?? 0).toDouble(),
    );
  }
}

class DistribucionEstado {
  final String estado;
  final int cantidad;

  DistribucionEstado({required this.estado, required this.cantidad});

  factory DistribucionEstado.fromJson(Map<String, dynamic> json) {
    return DistribucionEstado(
      estado: json['estado'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class DistribucionCategoria {
  final String categoria;
  final int cantidad;
  final double costoTotal;

  DistribucionCategoria({
    required this.categoria,
    required this.cantidad,
    required this.costoTotal,
  });

  factory DistribucionCategoria.fromJson(Map<String, dynamic> json) {
    return DistribucionCategoria(
      categoria: json['categoria'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      costoTotal: (json['costo_total'] ?? 0).toDouble(),
    );
  }
}

class DistribucionOrigen {
  final String origen;
  final int cantidad;

  DistribucionOrigen({required this.origen, required this.cantidad});

  factory DistribucionOrigen.fromJson(Map<String, dynamic> json) {
    return DistribucionOrigen(
      origen: json['origen'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class DistribucionPrioridad {
  final String prioridad;
  final int cantidad;

  DistribucionPrioridad({required this.prioridad, required this.cantidad});

  factory DistribucionPrioridad.fromJson(Map<String, dynamic> json) {
    return DistribucionPrioridad(
      prioridad: json['prioridad'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class TendenciaDiaria {
  final String fecha;
  final int cantidadReportada;

  TendenciaDiaria({required this.fecha, required this.cantidadReportada});

  factory TendenciaDiaria.fromJson(Map<String, dynamic> json) {
    return TendenciaDiaria(
      fecha: json['fecha'] ?? '',
      cantidadReportada: json['cantidad_reportada'] ?? 0,
    );
  }
}

class IncidenteCritico {
  final String incidentCode;
  final String connectionId;
  final String category;
  final String type;
  final int daysOpen;
  final double? latitude;
  final double? longitude;

  IncidenteCritico({
    required this.incidentCode,
    required this.connectionId,
    required this.category,
    required this.type,
    required this.daysOpen,
    this.latitude,
    this.longitude,
  });

  factory IncidenteCritico.fromJson(Map<String, dynamic> json) {
    return IncidenteCritico(
      incidentCode: json['incident_code'] ?? '',
      connectionId: json['connection_id'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      daysOpen: json['days_open'] ?? 0,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
