import 'package:flutter/foundation.dart';

/// Repository abstracto para archivos
abstract class FileRepository {
  /// Obtiene archivo para previsualización
  Future<Uint8List> preview({
    required FileCategory type,
    required String filename,
  });

  /// Obtiene archivo para descarga
  Future<Uint8List> download({
    required FileCategory type,
    required String filename,
  });
}

/// Categorías de archivos (debe coincidir con el backend)
enum FileCategory {
  incidents,
  readings,
  qrcodes,
  connections,
  workOrders;

  String get value {
    switch (this) {
      case FileCategory.incidents:
        return 'incidents';
      case FileCategory.readings:
        return 'readings';
      case FileCategory.qrcodes:
        return 'qrcodes';
      case FileCategory.connections:
        return 'connections';
      case FileCategory.workOrders:
        return 'work_orders';
    }
  }
}
