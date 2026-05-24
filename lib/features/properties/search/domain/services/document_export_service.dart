import 'dart:typed_data';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/entities/document_type.dart';

abstract interface class DocumentExportService {
  /// Generates and exports a specific document type for a given water connection.
  Future<void> exportConnectionDocument(ConnectionEntity connection, DocumentType type);

  /// Generates and exports the "Acta de Inspección/Instalación" for a given water connection.
  Future<void> exportConnectionActa(ConnectionEntity connection);

  /// Generates and returns the PDF bytes for the "Acta de Inspección/Instalación".
  Future<Uint8List> generateConnectionActaBytes(ConnectionEntity connection);
}
