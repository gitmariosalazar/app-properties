import 'package:flutter/services.dart' show rootBundle;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InformeTablaTemplate implements PdfTemplate {
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
    if (connection.person != null) {
      final p = connection.person!;
      ownerName = '${p.firstName ?? ""} ${p.lastName ?? ""}'.trim().toUpperCase();
    } else if (connection.company != null) {
      final c = connection.company!;
      ownerName = (c.businessName ?? c.commercialName ?? 'Compañía').toUpperCase();
    }

    final printDateFormatted = _formatDate(DateTime.now().toIso8601String());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
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
                            'EPAA-AA - DIRECCIÓN TÉCNICA',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                          ),
                          pw.Text(
                            'REPORTE SINTÉTICO DE ACOMETIDAS',
                            style: pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Text(
                    'INFORME TÉCNICO',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.blueGrey200),
              pw.SizedBox(height: 20),

              pw.Text(
                'CUADRO GENERAL DE ESPECIFICACIONES',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
              ),
              pw.SizedBox(height: 10),

              // --- TABLA DETALLADA ---
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellPadding: const pw.EdgeInsets.all(6),
                headers: ['PARÁMETRO TÉCNICO', 'VALOR REGISTRADO EN SISTEMA'],
                data: [
                  ['Código de Acometida', connection.connectionId],
                  ['Clave Catastral Principal', connection.connectionCadastralKey],
                  ['Contribuyente / Propietario', ownerName],
                  ['Número de Medidor', connection.connectionMeterNumber ?? 'Sin Medidor asignado'],
                  ['Número de Contrato', connection.connectionContractNumber ?? 'Sin Contrato asignado'],
                  ['Categoría de Servicio', connection.connectionRateName],
                  ['Dirección Declarada', connection.connectionAddress.isEmpty ? 'No especificada' : connection.connectionAddress],
                  ['Estado de Conexión', connection.connectionStateId == 1 ? 'OPERATIVO / ACTIVO' : 'SUSPENDIDO / INACTIVO'],
                  ['Disponibilidad de Lectura', connection.connectionIsReadable == true ? 'HABILITADA' : 'INHABILITADA'],
                  ['Alcantarillado Integrado', connection.connectionSewerage == true ? 'APLICA' : 'NO APLICA'],
                ],
              ),

              pw.Spacer(),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SIGEPAA-AA - Sistema de Catastro de Propiedades',
                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                  ),
                  pw.Text(
                    'Generado el: $printDateFormatted',
                    style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
                  ),
                ],
              ),
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
