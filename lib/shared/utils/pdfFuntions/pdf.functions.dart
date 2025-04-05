import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdf;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:qr_flutter/qr_flutter.dart';

Future<Uint8List> _generatePdfAndConvertToImages(
    List<Future<pw.Page>> pages) async {
  final pdf = pw.Document();
  final resolvedPages = await Future.wait(pages);
  for (var page in resolvedPages) {
    pdf.addPage(page);
  }
  return pdf.save();
}

Future<Uint8List> pagesToFile(List<pw.Page> pages) async {
  final pdf = pw.Document();
  for (final page in pages) {
    pdf.addPage(page);
  }
  return pdf.save();
}

Future<List<pdf.PdfPageImage?>> getImages(List<Future<pw.Page>> pages) async {
  final List<pdf.PdfPageImage?> images = [];
  final pdfData = await _generatePdfAndConvertToImages(pages);
  final document = await pdf.PdfDocument.openData(pdfData);

  for (int i = 1; i <= document.pagesCount; i++) {
    final page = await document.getPage(i);
    final image = await page.render(
      width: page.width,
      height: page.height,
      format: pdf.PdfPageImageFormat.png,
      backgroundColor: '#ffffff',
    );
    images.add(image);
  }
  return images;
}

Future<Uint8List> loadImage(String path) async {
  final ByteData data = await rootBundle.load('assets/images/$path');
  return data.buffer.asUint8List();
}

//----------------------------------------------------------------
Future<Uint8List?> generateQRCode(String urlQr, double size) async {
  final painter = QrPainter(
    data: urlQr,
    version: QrVersions.auto,
    gapless: false,
  );

  final image = await painter.toImage(size);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
//----------------------------------------------------------------

pw.Widget userFirm(String label) {
  return pw.Column(children: [
    pw.SizedBox(
      width: 150,
      child: pw.Divider(color: PdfColors.black),
    ),
    pw.Container(
        width: 200,
        child: pw.Text(label,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.black))),
  ]);
}

pw.Widget textFirma(String text) {
  return pw.Container(
      width: 200,
      child: pw.Text(text,
          textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10)));
}

Future<ui.Image> getImageDimensions(Uint8List fondoImageBytes) async {
  ui.Image image = await _loadImage(fondoImageBytes);
  return image;
}

Future<ui.Image> _loadImage(Uint8List bytes) async {
  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

pw.Widget cardCustom(pw.Widget childCustom) {
  return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: childCustom);
}

pw.Widget userDetail(String label, String? value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 160,
        child: pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
      ),
      pw.Text("$value"),
    ],
  );
}

pw.Widget userDetailEncabezado(String label, String? value) {
  return pw.Row(
    children: [
      pw.SizedBox(
        width: 80,
        child: pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
      ),
      pw.Text("$value"),
    ],
  );
}
