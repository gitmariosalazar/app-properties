import 'dart:io';

import 'package:equatable/equatable.dart';

class OldMeterData extends Equatable {
  final String? numeroMedidor;
  final double? ultimaLectura;
  final String? fechaUltimaLectura;

  const OldMeterData({
    this.numeroMedidor,
    this.ultimaLectura,
    this.fechaUltimaLectura,
  });

  @override
  List<Object?> get props => [numeroMedidor, ultimaLectura, fechaUltimaLectura];

  Map<String, dynamic> toJson() {
    return {
      if (numeroMedidor != null) 'numero_medidor': numeroMedidor,
      if (ultimaLectura != null) 'ultima_lectura': ultimaLectura,
      if (fechaUltimaLectura != null) 'fecha_ultima_lectura': fechaUltimaLectura,
    };
  }
}

class NewMeterData extends Equatable {
  final String? numeroMedidor;
  final double? lecturaAnterior;
  final double? lecturaActual;
  final String? fechaUltimaLectura;

  const NewMeterData({
    this.numeroMedidor,
    this.lecturaAnterior,
    this.lecturaActual,
    this.fechaUltimaLectura,
  });

  @override
  List<Object?> get props =>
      [numeroMedidor, lecturaAnterior, lecturaActual, fechaUltimaLectura];

  Map<String, dynamic> toJson() {
    return {
      if (numeroMedidor != null) 'numero_medidor': numeroMedidor,
      if (lecturaAnterior != null) 'lectura_anterior': lecturaAnterior,
      if (lecturaActual != null) 'lectura_actual': lecturaActual,
      if (fechaUltimaLectura != null) 'fecha_ultima_lectura': fechaUltimaLectura,
    };
  }
}

class IncidentChangeDetail extends Equatable {
  final String? claveCatastral;
  final String? numeroMedidor;
  final String? serie;
  final String? ubicacion;
  final String? observaciones;
  final OldMeterData? medidorAnterior;
  final NewMeterData? medidorNuevo;

  const IncidentChangeDetail({
    this.claveCatastral,
    this.numeroMedidor,
    this.serie,
    this.ubicacion,
    this.observaciones,
    this.medidorAnterior,
    this.medidorNuevo,
  });

  @override
  List<Object?> get props => [
        claveCatastral,
        numeroMedidor,
        serie,
        ubicacion,
        observaciones,
        medidorAnterior,
        medidorNuevo,
      ];

  Map<String, dynamic> toJson() {
    return {
      if (claveCatastral != null) 'clave_catastral': claveCatastral,
      if (numeroMedidor != null) 'numero_medidor': numeroMedidor,
      if (serie != null) 'serie': serie,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (observaciones != null) 'observaciones': observaciones,
      if (medidorAnterior != null) 'medidor_anterior': medidorAnterior!.toJson(),
      if (medidorNuevo != null) 'medidor_nuevo': medidorNuevo!.toJson(),
    };
  }
}

class ResolveIncidentRequest extends Equatable {
  final String description;
  final double repairCost;
  final bool chargeToUser;
  final List<File> images;
  final List<IncidentChangeDetail>? changeDetails;

  const ResolveIncidentRequest({
    required this.description,
    required this.repairCost,
    required this.chargeToUser,
    required this.images,
    this.changeDetails,
  });

  @override
  List<Object?> get props => [
        description,
        repairCost,
        chargeToUser,
        images,
        changeDetails,
      ];

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'repairCost': repairCost,
      'chargeToUser': chargeToUser,
      'images': images,
      if (changeDetails != null)
        'changeDetails': changeDetails!.map((e) => e.toJson()).toList(),
    };
  }
}
