import 'dart:typed_data';
import 'pdf_template.dart';

abstract interface class PdfExportService {
  /// Generates and shares/downloads a PDF document using the provided template and data.
  Future<void> exportDocument<T>({
    required T data,
    required String filename,
    required PdfTemplate<T> template,
  });

  /// Generates and returns the raw PDF bytes using the provided template and data.
  Future<Uint8List> generateDocumentBytes<T>({
    required T data,
    required PdfTemplate<T> template,
  });
}
