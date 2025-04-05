import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.functions.dart';

Future<pw.Page> generateDiploma(Personal? personal, String equipo) async {
  final image = await loadImage('diploma_full.png');
  final dimensionsImage = await getImageDimensions(image);
  var nombreCompleto = '';

  if (personal != null) {
    nombreCompleto = personal.nombreCompleto!;
  }

  final page = pw.Page(
    orientation: pw.PageOrientation.landscape,
    pageFormat: PdfPageFormat.a4.copyWith(
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
      marginTop: 0,
    ),
    build: (pw.Context context) {
      return pw.Container(
        child: pw.Stack(
          children: [
            pw.Image(
              pw.MemoryImage(image),
            ),
            pw.Row(
              children: [
                pw.Spacer(),
                pw.Container(
                  padding: const pw.EdgeInsets.only(left: 80),
                  child: pw.Column(
                    children: [
                      pw.SizedBox(height: dimensionsImage.height / 2.75),
                      pw.Text(
                        nombreCompleto,
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: dimensionsImage.height / 14),
                      pw.SizedBox(height: 15),
                      pw.Text(equipo, style: const pw.TextStyle(fontSize: 12)),
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 30),
                        alignment: pw.Alignment.center,
                        width: 500,
                        child: pw.Column(
                          children: [
                            pw.SizedBox(height: 50),
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceAround,
                              children: [
                                textFirma(
                                  'SUPERINTENDENTE DE OPERACIONES MINA',
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 10),
                                  child: textFirma(
                                    'SUPERINTENDENTE DE MEJORA CONTINUA Y CONTROL DE PRODUCCIÓN',
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 10),
                            textFirma('GERENTE MINA'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return page;
}
