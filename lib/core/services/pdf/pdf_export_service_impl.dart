import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'pdf_export_service.dart';
import 'pdf_template.dart';

class PdfExportServiceImpl implements PdfExportService {
  @override
  Future<void> exportDocument<T>({
    required T data,
    required String filename,
    required PdfTemplate<T> template,
  }) async {
    // 1. Generate the PDF document using the provided generic template
    final pdf = await template.generate(data);

    // 2. Natively share via Email, WhatsApp, etc.
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  @override
  Future<Uint8List> generateDocumentBytes<T>({
    required T data,
    required PdfTemplate<T> template,
  }) async {
    // 1. Generate the PDF document
    final pdf = await template.generate(data);
    
    // 2. Return raw bytes
    return pdf.save();
  }
}
