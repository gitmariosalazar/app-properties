import 'package:flutter/services.dart' show rootBundle;
import 'package:app_properties/features/properties/search/domain/entities/connection.dart';
import 'package:app_properties/features/properties/search/domain/services/pdf_templates/pdf_template.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ActaTemplate implements PdfTemplate {
  @override
  Future<pw.Document> generate(ConnectionEntity connection) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/epaa.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Ignorar si no carga y continuar sin logo
    }

    // Owner details extraction
    String ownerName = 'Sin Propietario Registrado';
    String ownerId = 'Sin identificación';
    String ownerContact = 'Sin contacto';
    String ownerAddress = 'Sin dirección';

    if (connection.person != null) {
      final p = connection.person!;
      ownerName = '${p.firstName ?? ""} ${p.lastName ?? ""}'
          .trim()
          .toUpperCase();
      ownerId = p.personId;
      final phones = p.phones
          .where((ph) => ph != null)
          .map((ph) => ph!.numero)
          .join(', ');
      final emails = p.emails
          .where((e) => e != null)
          .map((e) => e!.email)
          .join(', ');
      ownerContact = [
        if (phones.isNotEmpty) 'Tel: $phones',
        if (emails.isNotEmpty) 'Email: $emails',
      ].join(' | ');
      ownerAddress = p.address ?? 'Sin dirección domiciliaria';
    } else if (connection.company != null) {
      final c = connection.company!;
      ownerName = (c.businessName ?? c.commercialName ?? 'Compañía')
          .toUpperCase();
      ownerId = c.ruc;
      final phones = c.phones
          .where((ph) => ph != null)
          .map((ph) => ph!.numero)
          .join(', ');
      final emails = c.emails
          .where((e) => e != null)
          .map((e) => e!.email)
          .join(', ');
      ownerContact = [
        if (phones.isNotEmpty) 'Tel: $phones',
        if (emails.isNotEmpty) 'Email: $emails',
      ].join(' | ');
      ownerAddress = c.address ?? 'Sin dirección registrada';
    }

    final installationDateFormatted = _formatDate(
      connection.connectionInstallationDate,
    );
    final printDateFormatted = _formatDate(DateTime.now().toIso8601String());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 45,
                        height: 45,
                        margin: const pw.EdgeInsets.only(right: 12),
                        child: pw.Image(logoImage),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'EMPRESA PÚBLICA DE AGUA POTABLE Y ALCANTARILLADO \nDE ANTONIO ANTE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'EPAA - REGISTRO TÉCNICO',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            color: PdfColors.blueGrey600,
                          ),
                        ),
                        pw.Text(
                          'Atuntaqui, Ecuador',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            color: PdfColors.blueGrey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'ACTA DE ENTREGA - RECEPCIÓN',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Nº: ${connection.connectionId}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Divider(thickness: 1, color: PdfColors.blueGrey200),
            pw.SizedBox(height: 15),

            // --- INTRO / TÍTULO ---
            pw.Center(
              child: pw.Text(
                'CERTIFICADO DE INSTALACIÓN Y REGISTRO DE ACOMETIDA',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey800,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),

            // --- SECCIÓN 1: DATOS DEL PROPIETARIO ---
            _buildSectionHeader('1. DATOS DEL PROPIETARIO'),
            _buildGridRow([
              _buildGridCell(
                'Nombres / Razón Social',
                ownerName,
                isTitle: true,
              ),
            ]),
            _buildGridRow([
              _buildGridCell('Identificación (Cédula/RUC)', ownerId),
              _buildGridCell('Contacto', ownerContact),
            ]),
            _buildGridRow([
              _buildGridCell('Dirección Domicilio', ownerAddress),
            ]),
            pw.SizedBox(height: 15),

            // --- SECCIÓN 2: ESPECIFICACIONES TÉCNICAS ---
            _buildSectionHeader('2. ESPECIFICACIONES TÉCNICAS DE LA ACOMETIDA'),
            _buildGridRow([
              _buildGridCell(
                'Clave Catastral',
                connection.connectionCadastralKey,
              ),
              _buildGridCell('Tipo de Tarifa', connection.connectionRateName),
            ]),
            _buildGridRow([
              _buildGridCell(
                'Número de Medidor',
                connection.connectionMeterNumberCurrent ?? 'Sin Medidor',
              ),
              _buildGridCell(
                'Número de Medidor Anterior',
                connection.connectionMeterNumberPreview ?? 'Sin Medidor',
              ),
            ]),
            _buildGridRow([
              _buildGridCell(
                'Número de Contrato',
                connection.connectionContractNumber ?? 'Sin Contrato',
              ),
            ]),
            _buildGridRow([
              _buildGridCell('Fecha de Instalación', installationDateFormatted),
              _buildGridCell(
                'Alcantarillado',
                connection.connectionSewerage == true
                    ? 'SÍ REGISTRA'
                    : 'NO REGISTRA',
              ),
            ]),
            _buildGridRow([
              _buildGridCell(
                'Lectura Habilitada',
                connection.connectionIsReadable == true
                    ? 'SÍ ACTIVA'
                    : 'NO ACTIVA',
              ),
              _buildGridCell(
                'Estado del Servicio',
                connection.connectionStateId == 1
                    ? 'ACTIVA / OPERATIVA'
                    : 'SUSPENDIDA / INACTIVA',
              ),
            ]),
            pw.SizedBox(height: 15),

            // --- SECCIÓN 3: UBICACIÓN GEOGRÁFICA Y PREDIO ---
            _buildSectionHeader('3. UBICACIÓN GEOGRÁFICA Y PREDIO'),
            _buildGridRow([
              _buildGridCell(
                'Dirección de Acometida',
                connection.connectionAddress.isEmpty
                    ? 'Sin dirección'
                    : connection.connectionAddress,
              ),
              _buildGridCell(
                'Zona de Cobertura',
                '${connection.zoneName ?? "No asignada"} (${connection.zoneCode ?? "NO_CODE"})',
              ),
            ]),
            if (connection.property != null) ...[
              _buildGridRow([
                _buildGridCell(
                  'Clave Catastral Predio',
                  connection.property!.propertyCadastralKey,
                ),
                _buildGridCell(
                  'Tipo de Predio',
                  connection.property!.propertyTypeName,
                ),
              ]),
              _buildGridRow([
                _buildGridCell(
                  'Dirección del Predio',
                  connection.property!.propertyAddress,
                ),
                _buildGridCell(
                  'Callejón / Vía de Acceso',
                  connection.property!.propertyAlleyway.isEmpty
                      ? 'No especificada'
                      : connection.property!.propertyAlleyway,
                ),
              ]),
            ],
            _buildGridRow([
              _buildGridCell(
                'Coordenadas GPS',
                connection.connectionCoordinates ?? 'Sin coordenadas GPS',
              ),
              _buildGridCell(
                'Precisión Satelital',
                connection.connectionPrecision != null
                    ? '${connection.connectionPrecision!.toStringAsFixed(2)} metros'
                    : 'No registrada',
              ),
            ]),
            pw.SizedBox(height: 35),

            // --- PIE DE PÁGINA / FIRMAS ---
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: PdfColors.blueGrey400,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Firma del Inspector',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      'Departamento Técnico EPAA',
                      style: pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.blueGrey500,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                            color: PdfColors.blueGrey400,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Firma del Propietario',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.Text(
                      'C.I. / RUC: $ownerId',
                      style: pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.blueGrey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 25),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Documento generado el: $printDateFormatted | EPAA-AA Mobile System',
                style: pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.blueGrey400,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: const pw.BoxDecoration(
        color: PdfColors.blueGrey800,
        borderRadius: pw.BorderRadius.only(
          topLeft: pw.Radius.circular(4),
          topRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildGridRow(List<pw.Widget> cells) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(cells.length, (index) {
        return pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: cells[index],
          ),
        );
      }),
    );
  }

  pw.Widget _buildGridCell(String label, String value, {bool isTitle = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 6,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTitle ? 9 : 8,
            fontWeight: isTitle ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
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
