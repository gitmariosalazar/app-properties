import 'package:app_properties/features/properties/search/domain/entities/document_type.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/pdf_template.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/acta_template.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/informe_tabla_template.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/solicitud_template.dart';

class PdfTemplateFactory {
  /// Retorna la estrategia de plantilla PDF adecuada según el tipo de documento.
  static PdfTemplate getTemplate(DocumentType type) {
    switch (type) {
      case DocumentType.acta:
        return ActaTemplate();
      case DocumentType.informeTabla:
        return InformeTablaTemplate();
      case DocumentType.solicitud:
        return SolicitudTemplate();
    }
  }
}
