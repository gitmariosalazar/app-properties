import '../../domain/entities/uploaded_document.dart';

class UploadedDocumentModel extends UploadedDocument {
  const UploadedDocumentModel({
    required super.documentoId,
    required super.tipoDocumentoId,
    required super.codigoTipo,
    required super.nombreOriginal,
    required super.mimeType,
    required super.fileSizeBytes,
    required super.estado,
    required super.nivelAcceso,
    super.downloadUrl,
  });

  factory UploadedDocumentModel.fromJson(Map<String, dynamic> rawJson) {
    // 1. Detectar si la respuesta viene envuelta en un objeto { "documento": ... }
    final Map<String, dynamic> json = rawJson.containsKey('documento')
        ? rawJson['documento'] as Map<String, dynamic>
        : rawJson;

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) {
        return int.tryParse(val) ?? 0;
      }
      if (val is double) {
        return val.toInt();
      }
      return 0;
    }

    return UploadedDocumentModel(
      documentoId: (json['documento_id'] ?? '').toString(),
      tipoDocumentoId: parseInt(json['tipo_documento_id']),
      codigoTipo: (json['codigo_tipo'] ?? '').toString(),
      nombreOriginal: (json['nombre_original'] ?? '').toString(),
      mimeType: (json['mime_type'] ?? '').toString(),
      fileSizeBytes: parseInt(json['file_size_bytes']),
      estado: (json['estado'] ?? '').toString(),
      nivelAcceso: (json['nivel_acceso'] ?? '').toString(),
      downloadUrl: json['downloadUrl'] as String? ?? rawJson['downloadUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documento_id': documentoId,
      'tipo_documento_id': tipoDocumentoId,
      'codigo_tipo': codigoTipo,
      'nombre_original': nombreOriginal,
      'mime_type': mimeType,
      'file_size_bytes': fileSizeBytes,
      'estado': estado,
      'nivel_acceso': nivelAcceso,
      'downloadUrl': downloadUrl,
    };
  }
}
