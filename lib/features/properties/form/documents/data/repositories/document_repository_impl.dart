import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failure.dart';
import '../../domain/entities/uploaded_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UploadedDocument>> uploadDocument({
    required Uint8List fileBytes,
    required String filename,
    required String codigoTipoDocumento,
    required String entityType,
    required String entityId,
    String? nivelAcceso,
    List<String>? rolesPermitidos,
    Map<String, dynamic>? metadatosExtras,
  }) async {
    try {
      final result = await remoteDataSource.uploadDocument(
        fileBytes: fileBytes,
        filename: filename,
        codigoTipoDocumento: codigoTipoDocumento,
        entityType: entityType,
        entityId: entityId,
        nivelAcceso: nivelAcceso,
        rolesPermitidos: rolesPermitidos,
        metadatosExtras: metadatosExtras,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
