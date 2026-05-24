import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failure.dart';
import '../entities/uploaded_document.dart';

abstract class DocumentRepository {
  Future<Either<Failure, UploadedDocument>> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String codigoTipoDocumento,
    required String entityType,
    required String entityId,
    String? nivelAcceso,
    List<String>? rolesPermitidos,
    Map<String, dynamic>? metadatosExtras,
  });
}
