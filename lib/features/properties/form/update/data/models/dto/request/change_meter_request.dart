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

class MeterChangeDetail extends Equatable {
  final String? claveCatastral;
  final String? numeroMedidor;
  final String? serie;
  final String? ubicacion;
  final String? observaciones;
  final OldMeterData? medidorAnterior;
  final NewMeterData? medidorNuevo;

  const MeterChangeDetail({
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

class ChangeMeterRequest extends Equatable {
  final String connectionId;
  final MeterChangeDetail changeDetail;
  final List<File> images;
  final List<String> imageDescriptions;

  const ChangeMeterRequest({
    required this.connectionId,
    required this.changeDetail,
    required this.images,
    required this.imageDescriptions,
  });

  @override
  List<Object?> get props => [
        connectionId,
        changeDetail,
        images,
        imageDescriptions,
      ];
}
