import 'package:pdf/widgets.dart' as pw;

/// Contrato base para generar plantillas PDF de cualquier tipo de entidad <T>.
abstract interface class PdfTemplate<T> {
  /// Genera un documento [pw.Document] a partir de los datos [T].
  Future<pw.Document> generate(T data);
}
