import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failure.dart';
import '../entities/uploaded_document.dart';
import '../repositories/document_repository.dart';

class UploadDocumentUseCase {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, UploadedDocument>> call({
    required Uint8List fileBytes,
    required String filename,
    required String codigoTipoDocumento,
    required String entityType,
    required String entityId,
    String? nivelAcceso,
    List<String>? rolesPermitidos,
    Map<String, dynamic>? metadatosExtras,
  }) {
    return repository.uploadDocument(
      fileBytes: fileBytes,
      filename: filename,
      codigoTipoDocumento: codigoTipoDocumento,
      entityType: entityType,
      entityId: entityId,
      nivelAcceso: nivelAcceso,
      rolesPermitidos: rolesPermitidos,
      metadatosExtras: metadatosExtras,
    );
  }
}
