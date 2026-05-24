import 'package:flutter/services.dart' show rootBundle;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SolicitudTemplate implements PdfTemplate {
  @override
  Future<pw.Document> generate(ConnectionEntity connection) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/epaa.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Ignorar si falla
    }

    String ownerName = 'Sin Propietario Registrado';
    String ownerId = 'Sin identificación';
    if (connection.person != null) {
      final p = connection.person!;
      ownerName = '${p.firstName ?? ""} ${p.lastName ?? ""}'.trim().toUpperCase();
      ownerId = p.personId;
    } else if (connection.company != null) {
      final c = connection.company!;
      ownerName = (c.businessName ?? c.commercialName ?? 'Compañía').toUpperCase();
      ownerId = c.ruc;
    }

    final printDateFormatted = _formatDate(DateTime.now().toIso8601String());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(45),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- LOGO / CABECERA ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 35,
                          height: 35,
                          margin: const pw.EdgeInsets.only(right: 10),
                          child: pw.Image(logoImage),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'EMPRESA PÚBLICA EPAA-AA',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                          ),
                          pw.Text(
                            'ÁREA DE SERVICIO AL CLIENTE',
                            style: pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Text(
                    'FORMULARIO FS-01',
                    style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Divider(thickness: 1, color: PdfColors.blueGrey300),
              pw.SizedBox(height: 25),

              // --- FECHA Y DESTINATARIO ---
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Atuntaqui, $printDateFormatted',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 25),

              pw.Text(
                'Señores:\nDEPARTAMENTO DE CATASTRO Y FACTURACIÓN\nEmpresa Pública de Agua Potable y Alcantarillado\nPresente.-',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.SizedBox(height: 25),

              // --- ASUNTO ---
              pw.Row(
                children: [
                  pw.Text(
                    'ASUNTO: ',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Solicitud de Inspección Técnica / Cambio de Estado de Acometida',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // --- CUERPO ---
              pw.Text(
                'De mi consideración:\n\n'
                'Yo, $ownerName, portador de la identificación Nº $ownerId, en calidad de propietario/representante legal del inmueble registrado bajo la Clave Catastral Nº ${connection.connectionCadastralKey}, ubicado en la dirección ${connection.connectionAddress.isEmpty ? "Sin dirección registrada" : connection.connectionAddress}, me dirijo respetuosamente ante ustedes para solicitar una inspección formal de la acometida correspondiente al código de conexión Nº ${connection.connectionId}.\n\n'
                'Esta petición se realiza con el propósito de verificar el estado técnico actual de la instalación, confirmar la lectura habilitada y validar la correcta facturación de los servicios de agua potable y alcantarillado registrados en su sistema.\n\n'
                'Agradeciendo de antemano la atención brindada a la presente solicitud, suscribo de ustedes.',
                style: const pw.TextStyle(fontSize: 10, height: 1.5),
                textAlign: pw.TextAlign.justify,
              ),

              pw.Spacer(),

              // --- FIRMAS ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('Atentamente,', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 55),
                    pw.Container(
                      width: 200,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(color: PdfColors.blueGrey800, width: 0.8)),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(ownerName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('C.I. / RUC: $ownerId', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                    pw.Text('SOLICITANTE', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'No registrada';
    try {
      final parsed = DateTime.parse(rawDate);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate;
    }
  }
}
