import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:image/image.dart';

// Procesar una imagen (rotar, redimensionar y/o comprimir)
Future<Uint8List> processImageAsync(Uint8List imageBytes,
    {int? width, int quality = 100, bool rotate = false}) async {
  return await Future(() {
    final image = decodeImage(imageBytes);
    if (image == null) return imageBytes;

    Image processedImage = image;

    if (width != null) {
      processedImage = copyResize(processedImage, width: width);
    }

    if (rotate) {
      processedImage = copyRotate(processedImage, angle: 90);
    }

    return Uint8List.fromList(encodeJpg(processedImage, quality: quality));
  });
}

// Convertir una imagen a escala de grises
Future<Uint8List> convertToGrayscaleAsync(Uint8List imageBytes) async {
  return await Future(() {
    final decodedImage = decodeImage(imageBytes);
    if (decodedImage != null) {
      final grayImage = grayscale(decodedImage);
      return Uint8List.fromList(encodeJpg(grayImage, quality: 100));
    }
    return imageBytes;
  });
}

// Generar el PDF dinámicamente con imágenes distribuidas en filas y columnas
pw.Widget generateDynamicGrid(List<PdfPageImage?> images,
    {int columns = 2, int imageWidth = 800}) {
  final rows = (images.length / columns).ceil();

  return pw.Column(
    children: List.generate(rows, (rowIndex) {
      return pw.Row(
        children: List.generate(columns, (colIndex) {
          final imageIndex = rowIndex * columns + colIndex;

          if (imageIndex < images.length && images[imageIndex] != null) {
            return pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Image(
                  pw.MemoryImage(images[imageIndex]!.bytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
          } else {
            return pw.Expanded(child: pw.Container()); // Espacio vacío
          }
        }),
      );
    }),
  );
}

Future<Uint8List> pdfToBytes(
  List<PdfPageImage?> imagess, {
  bool rotar = false,
  int columns = 2,
  double margin = 10.0,
}) async {
  if (imagess.isEmpty) {
    throw Exception("No hay imágenes para generar el PDF.");
  }

  final pdf = pw.Document();

  for (var i = 0; i < imagess.length; i++) {
    final image = imagess[i];
    if (image != null) {
      final processedImage =
          await processImageAsync(image.bytes, rotate: rotar);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(margin),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(processedImage),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Permitir que el navegador procese eventos
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  // Guardar y descargar el PDF
  return pdf.save();
}

// Descargar un PDF generado con una o más páginas
Future<void> descargarPaginasComoPdf(List<PdfPageImage?> imagess,
    {String nombreArchivo = "documento.pdf",
    bool rotar = false,
    int columns = 2,
    double margin = 10.0}) async {
  final bytes = await pdfToBytes(
    imagess,
    rotar: rotar,
    columns: columns,
    margin: margin,
  );

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', nombreArchivo)
    ..click();
  html.Url.revokeObjectUrl(url);
}

// Descargar una sola página como PDF
Future<void> descargarPaginaComoPdf(Future<List<PdfPageImage?>> imagess,
    {String nombreArchivo = "documento.pdf", bool rotar = false}) async {
  var images = await imagess;

  if (images.isEmpty) {
    print("No hay imágenes para generar el PDF.");
    return;
  }

  await descargarPaginasComoPdf(images,
      nombreArchivo: nombreArchivo, rotar: rotar);
}

// Generar una columna dinámica de carnets (dos imágenes por columna)
pw.Widget _columnCarnet(
    List<PdfPageImage?> images, int position1, int position2) {
  return pw.Column(
    mainAxisAlignment: pw.MainAxisAlignment.center,
    children: [
      pw.Expanded(
        child: (position1 < images.length && images[position1] != null)
            ? pw.Image(
                pw.MemoryImage(images[position1]!.bytes),
              )
            : pw.Container(),
      ),
      pw.Expanded(
        child: (position2 < images.length && images[position2] != null)
            ? pw.Image(
                pw.MemoryImage(images[position2]!.bytes),
              )
            : pw.Container(),
      ),
    ],
  );
}

// Método para generar una página del PDF desde imágenes
Future<pw.Page> generatePdfPageFromImages(
    Future<List<PdfPageImage?>> imagess) async {
  var images = await imagess;
  return generatePdfPagesFromImages(images);
}

// Método para generar varias páginas del PDF desde imágenes
Future<pw.Page> generatePdfPagesFromImages(List<PdfPageImage?> imagess) async {
  var images = imagess;

  // Calcular columnas dinámicamente (2 imágenes por columna)
  final int totalColumns = (images.length / 2).ceil();

  return pw.Page(
    orientation: pw.PageOrientation.portrait,
    margin: const pw.EdgeInsets.all(10),
    build: (pw.Context context) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: List.generate(
          totalColumns,
          (index) {
            final int position1 = index * 2;
            final int position2 = position1 + 1;

            return _columnCarnet(images, position1, position2);
          },
        ),
      );
    },
  );
}

//New
//carnet todo en pdf
Future<Uint8List> pdfToBytesNew(
  List<PdfPageImage?> imagess, {
  bool rotar = false,
  double margin = 10.0,
}) async {
  if (imagess.isEmpty) {
    throw Exception("No hay imágenes para generar el PDF.");
  }

  final pdf = pw.Document();

  // Procesa las imágenes y rota el contenido para que sea vertical
  final processedImages = await Future.wait(imagess.map((image) async {
    if (image == null) return null;
    return await processImageAsync(image.bytes, rotate: rotar);
  }));

  // Añade una página A4 horizontal con imágenes duplicadas (una encima de otra)
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.all(margin),
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              children: [
                pw.Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  alignment: pw.WrapAlignment.center,
                  children: processedImages
                      .where((img) => img != null)
                      .expand(
                        (img) => [
                          pw.Container(
                            width: 54 * PdfPageFormat.mm,
                            height: 85 * PdfPageFormat.mm,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black, width: 1),
                            ),
                            child: pw.Image(
                              pw.MemoryImage(img!),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        ],
                      )
                      .toList(),
                ),
                pw.Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  alignment: pw.WrapAlignment.center,
                  children: processedImages
                      .where((img) => img != null)
                      .expand(
                        (img) => [
                          pw.Container(
                            width: 54 * PdfPageFormat.mm,
                            height: 85 * PdfPageFormat.mm,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(
                                  color: PdfColors.black, width: 1),
                            ),
                            child: pw.Image(
                              pw.MemoryImage(img!),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        ],
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  // Guardar y descargar el PDF
  return pdf.save();
}

Future<void> descargarPaginasComoPdfNew(List<PdfPageImage?> imagess,
    {String nombreArchivo = "documento.pdf",
    bool rotar = true,
    int columns = 2,
    double margin = 10.0}) async {
  final bytes = await pdfToBytesNew(
    imagess,
    rotar: rotar,
    margin: margin,
  );

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', nombreArchivo)
    ..click();
  html.Url.revokeObjectUrl(url);
}
