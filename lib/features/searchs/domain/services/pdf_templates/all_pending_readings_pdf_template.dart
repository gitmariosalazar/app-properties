import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_properties/core/services/pdf/pdf_template.dart';
import 'package:app_properties/features/searchs/domain/entities/pending_reading_response.model.dart';

class AllPendingReadingsPdfTemplate
    implements PdfTemplate<List<PendingReadingResponse>> {
  @override
  Future<pw.Document> generate(List<PendingReadingResponse> readings) async {
    final pdf = pw.Document();

    // Optionally load a logo if available in assets (fallback to text if not)
    pw.MemoryImage? logoImage;
    try {
      final ByteData data = await rootBundle.load('assets/images/epaa.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      // Ignored if logo doesn't exist
    }

    for (final reading in readings) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(logoImage),
              pw.SizedBox(height: 20),
              _buildTitle(),
              pw.SizedBox(height: 20),
              _buildUserInfo(reading),
              pw.SizedBox(height: 20),
              _buildGeneralTable(reading),
              pw.SizedBox(height: 20),
              _buildTrashRateTable(reading),
              pw.SizedBox(height: 20),
              _buildMejorasTable(reading),
              pw.SizedBox(height: 20),
              _buildGrandTotal(reading),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: const pw.TextStyle(color: PdfColors.grey),
              ),
            );
          },
        ),
      );
    }

    return pdf;
  }

  pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoImage != null)
          pw.Image(logoImage, width: 80)
        else
          pw.Text(
            'EPAA',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'EMPRESA PÚBLICA DE AGUA POTABLE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.Text(
              'Y ALCANTARILLADO ANTONIO ANTE',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.Text(
              'RUC: 1060000280001',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTitle() {
    return pw.Center(
      child: pw.Text(
        'DETALLE DE PLANILLA Y DEUDA',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  pw.Widget _buildUserInfo(PendingReadingResponse reading) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                'Contribuyente:',
                '${reading.name} ${reading.lastName}',
              ),
              _buildInfoRow('Identificación:', reading.cardId),
              _buildInfoRow('Dirección:', reading.address),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Clave Catastral:', reading.cadastralKey),
              _buildInfoRow('Tarifa:', reading.rate),
              _buildInfoRow('Estado:', reading.incomeStatus),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
          pw.SizedBox(width: 8),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildGeneralTable(PendingReadingResponse reading) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Planilla General',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: [
            'Periodo',
            'Consumo (m³)',
            'Valor EPAA',
            'Interés',
            'Recargo',
            'Total',
          ],
          data: [
            [
              '${reading.month} - ${reading.year}',
              '${reading.consumption}',
              '\$${reading.epaaValue.toStringAsFixed(2)}',
              '\$${reading.interestValue.toStringAsFixed(2)}',
              reading.surcharge > 0
                  ? '\$${reading.surcharge.toStringAsFixed(2)}'
                  : '-',
              '\$${reading.totalEpaaValue.toStringAsFixed(2)}',
            ],
          ],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  pw.Widget _buildTrashRateTable(PendingReadingResponse reading) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detalle Tasa Basura',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: [
            'Periodo',
            'TB Actual',
            'TB Anterior',
            'Saldo a Favor',
            'Saldo (Próx. Mes)',
            'Total a Pagar',
          ],
          data: [
            [
              '${reading.month} - ${reading.year}',
              '\$${reading.trashRate.toStringAsFixed(2)}',
              '\$${reading.trashRatePrevious.toStringAsFixed(2)}',
              reading.balanceInFavorCurrentMonth > 0
                  ? '\$${reading.balanceInFavorCurrentMonth.toStringAsFixed(2)}'
                  : '-',
              reading.balanceInFavorNextMonth > 0
                  ? '\$${reading.balanceInFavorNextMonth.toStringAsFixed(2)}'
                  : '-',
              '\$${reading.totalTrashRate.toStringAsFixed(2)}',
            ],
          ],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.black,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.yellow200),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
            5: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  pw.Widget _buildMejorasTable(PendingReadingResponse reading) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Mejoras Municipio Antonio Ante',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Periodo', 'Valor Mejoras', 'Total a Pagar'],
          data: [
            [
              '${reading.month} - ${reading.year}',
              '\$${reading.thirdPartyValue.toStringAsFixed(2)}',
              '\$${reading.thirdPartyValue.toStringAsFixed(2)}',
            ],
          ],
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColors.black,
          ),
          headerDecoration: pw.BoxDecoration(color: PdfColors.blue100),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
          },
        ),
      ],
    );
  }

  pw.Widget _buildGrandTotal(PendingReadingResponse reading) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'GRAN TOTAL:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
            pw.Text(
              '\$${reading.adjustedTotal.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
