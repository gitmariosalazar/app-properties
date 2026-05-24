import 'package:equatable/equatable.dart';

class UploadedDocument extends Equatable {
  final String documentoId;
  final int tipoDocumentoId;
  final String codigoTipo;
  final String nombreOriginal;
  final String mimeType;
  final int fileSizeBytes;
  final String estado;
  final String nivelAcceso;
  final String? downloadUrl;

  const UploadedDocument({
    required this.documentoId,
    required this.tipoDocumentoId,
    required this.codigoTipo,
    required this.nombreOriginal,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.estado,
    required this.nivelAcceso,
    this.downloadUrl,
  });

  @override
  List<Object?> get props => [
        documentoId,
        tipoDocumentoId,
        codigoTipo,
        nombreOriginal,
        mimeType,
        fileSizeBytes,
        estado,
        nivelAcceso,
        downloadUrl,
      ];
}
