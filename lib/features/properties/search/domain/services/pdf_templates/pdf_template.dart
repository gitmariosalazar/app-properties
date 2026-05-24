import 'package:pdf/widgets.dart' as pw;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';

abstract interface class PdfTemplate {
  /// Generates a highly stylized pw.Document for the given connection.
  Future<pw.Document> generate(ConnectionEntity connection);
}
