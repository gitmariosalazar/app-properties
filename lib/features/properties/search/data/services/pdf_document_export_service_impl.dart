import 'dart:typed_data';
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/entities/document_type.dart';
import 'package:app_properties/features/properties/search/domain/services/document_export_service.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/pdf_template_factory.dart';
import 'package:printing/printing.dart';

class PdfDocumentExportServiceImpl implements DocumentExportService {
  @override
  Future<void> exportConnectionDocument(ConnectionEntity connection, DocumentType type) async {
    // 1. Obtener la plantilla adecuada a través del Factory
    final template = PdfTemplateFactory.getTemplate(type);

    // 2. Generar el documento PDF
    final pdf = await template.generate(connection);

    // 3. Compartir nativamente a través de correo, WhatsApp, etc. (Menú de compartir del sistema)
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${type.name.toUpperCase()}_Acometida_${connection.connectionId}.pdf',
    );
  }

  @override
  Future<void> exportConnectionActa(ConnectionEntity connection) async {
    // Por retrocompatibilidad, generar y compartir la de tipo acta
    await exportConnectionDocument(connection, DocumentType.acta);
  }

  @override
  Future<Uint8List> generateConnectionActaBytes(ConnectionEntity connection) async {
    final template = PdfTemplateFactory.getTemplate(DocumentType.acta);
    final pdf = await template.generate(connection);
    return pdf.save();
  }
}
