import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/utils/PDFGenerators/generate.diploma.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.descargar.dart';
import 'package:sgem/shared/utils/pdfFuntions/pdf.functions.dart';
import 'package:sgem/shared/utils/widgets/future.view.pdf.dart';

class PdfToDiplomaScreen extends StatefulWidget {
  const PdfToDiplomaScreen({
    required this.personal,
    required this.controller,
    super.key,
  });

  final Personal? personal;
  final PersonalSearchController controller;

  @override
  State<PdfToDiplomaScreen> createState() => _PdfToDiplomaScreenState();
}

class _PdfToDiplomaScreenState extends State<PdfToDiplomaScreen> {
  Future<List<PdfPageImage?>>? _getdata;

  @override
  void initState() {
    super.initState();
    _getdata = getData();
  }

  Future<List<PdfPageImage?>> getData() async {
    try {
      final training =
          Get.find<EntrenamientoPersonalController>().selectedTraining.value!;
      final personalData = widget.personal;
      final listPages = <Future<pw.Page>>[
        generateDiploma(personalData, training.equipo!.nombre ?? ''),
      ];
      return getImages(listPages);
    } catch (error, stackTrace) {
      Logger('PdfToDiplomaScreen').severe(
        'Error al obtener datos',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    const angleRotacion = -pi / 2;

    return PdfViewer(
      futurePdf: _getdata,
      angleRotation: angleRotacion,
      onCancel: () {
        widget.controller.showTraining(widget.personal);
      },
      onPrint: (pages) {
        descargarPaginasComoPdf(
          pages,
          nombreArchivo: 'DIPLOMA_${widget.personal!.codigoMcp}',
        );
      },
    );
  }
}
