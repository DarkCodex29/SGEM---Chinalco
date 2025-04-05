import 'dart:developer';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/api/api_historial.dart';
import 'package:sgem/shared/models/historial_modificaciones.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class HistorialModificacionesController extends GetxController {
  HistorialModificacionesController({
    HistorialModificacionesService? historialModificacionesService,
  }) : _historialModificacionesService =
            historialModificacionesService ?? HistorialModificacionesService();
  final HistorialModificacionesService _historialModificacionesService;

  final TextEditingController usuarioAccion = TextEditingController();
  TextEditingController rangoFechaController = TextEditingController();

  TextEditingController tablaController = TextEditingController();
  TextEditingController accionController = TextEditingController();

  final DropdownController tablaDC = DropdownController();
  final DropdownController accionDC = DropdownController();

  final result = RxList<HistorialModificaciones>();

  RxBool isExpanded = true.obs;
  RxInt rowsPerPage = 10.obs;
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxInt totalRecords = 0.obs;
  RxList<HistorialModificaciones> historialAll =
      <HistorialModificaciones>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await searchHistorial(
      pageNumber: currentPage.value,
      pageSize: rowsPerPage.value,
    );
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    usuarioAccion.dispose();
    rangoFechaController.dispose();
    tablaDC.dispose();
    accionDC.dispose();
  }

  Future<void> searchHistorial({int pageNumber = 1, int pageSize = 10}) async {
    DateTime? fechaInicio;
    DateTime? fechaTermino;
    if (rangoFechaController.text.isNotEmpty) {
      final dates = rangoFechaController.text.split(' - ');

      fechaInicio = DateTime(
        int.parse(dates[0].split('/')[2]), // Año
        int.parse(dates[0].split('/')[1]), // Mes
        int.parse(dates[0].split('/')[0]), // Día
      );

      fechaTermino = DateTime(
        int.parse(dates[1].split('/')[2]), // Año
        int.parse(dates[1].split('/')[1]), // Mes
        int.parse(dates[1].split('/')[0]), // Día
      );
    }

    try {
      final response =
          await _historialModificacionesService.searchHistorialModificaciones(
        usuarioRegistro: usuarioAccion.text,
        fechaInicio: fechaInicio,
        fechaFin: fechaTermino,
        idTabla: tablaDC.value,
        idAccion: accionDC.value,
      );

      if (response.success && response.data != null) {
        final result = response.data!;

        final items = result['Items'] as List<HistorialModificaciones>;
        historialAll.assignAll(items);
        currentPage.value = result['PageNumber'] as int;
        totalPages.value = result['TotalPages'] as int;
        totalRecords.value = result['TotalRecords'] as int;
        rowsPerPage.value = result['PageSize'] as int;
        isExpanded.value = false;
      }
    } catch (e) {
      log('Error en la búsqueda de historial: $e');
    }
  }

  Future<void> downloadExcel() async {
    try {
      DateTime? fechaInicio;
      DateTime? fechaTermino;
      if (rangoFechaController.text.isNotEmpty) {
        final dates = rangoFechaController.text.split(' - ');

        fechaInicio = DateTime(
          int.parse(dates[0].split('/')[2]), // Año
          int.parse(dates[0].split('/')[1]), // Mes
          int.parse(dates[0].split('/')[0]), // Día
        );

        fechaTermino = DateTime(
          int.parse(dates[1].split('/')[2]), // Año
          int.parse(dates[1].split('/')[1]), // Mes
          int.parse(dates[1].split('/')[0]), // Día
        );
      }
      final response =
          await _historialModificacionesService.searchHistorialModificaciones(
        isPaginate: false,
        usuarioRegistro: usuarioAccion.text,
        fechaInicio: fechaInicio,
        fechaFin: fechaTermino,
        idTabla: tablaDC.value,
        idAccion: accionDC.value,
      );
      if (response.success && response.data != null) {
        final result = response.data!;

        final items = result['Items'] as List<HistorialModificaciones>;
        final excel = Excel.createExcel();
        excel.rename('Sheet1', 'Historial');

        final headerStyle = CellStyle(
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );
        final headers = <String>[
          'FECHA_ACCION',
          'USUARIO_ACCION',
          'TABLA',
          'ACCION',
          'REGISTRO',
        ];

        for (var i = 0; i < headers.length; i++) {
          excel.sheets['Historial']!
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            ..value = TextCellValue(headers[i])
            ..cellStyle = headerStyle;

          excel.sheets['Historial']!
              .setColumnWidth(i, headers[i].length.toDouble() + 5);
        }

        // final dateFormat = DateFormat('dd/MM/yyyy');

        for (var rowIndex = 0; rowIndex < items.length; rowIndex++) {
          final historial = items[rowIndex];
          final row = <CellValue>[
            TextCellValue(historial.fechaRegistro.formatExtended),
            TextCellValue(historial.usuarioRegistro),
            TextCellValue('${historial.tabla.nombre}'),
            TextCellValue('${historial.accion.nombre}'),
            TextCellValue(historial.registro),
          ];

          for (var colIndex = 0; colIndex < row.length; colIndex++) {
            excel.sheets['Historial']!
                .cell(
                  CellIndex.indexByColumnRow(
                    columnIndex: colIndex,
                    rowIndex: rowIndex + 1,
                  ),
                )
                .value = row[colIndex];
          }
        }

        final excelBytes = excel.encode();
        final uint8ListBytes = Uint8List.fromList(excelBytes!);

        final fileName = generateExcelFileName();
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: uint8ListBytes,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );
      }
    } catch (e) {
      debugPrint('Error al descargar el archivo Excel: $e');
    }
  }

  String generateExcelFileName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'HISTORIAL_MODIFICACIONES_MINA_$day$month$year$hour$minute$second';
  }

  void clear() {
    rangoFechaController.clear();
    tablaDC.clear();
    accionDC.clear();
    usuarioAccion.clear();
    searchHistorial();
  }

  List<String> historialFormat(HistorialModificaciones item) {
    return [
      item.fechaRegistro.formatExtended,
      item.usuarioRegistro,
      item.tabla.nombre ?? '-',
      item.accion.nombre ?? '-',
      item.registro,
    ];
  }

  void parsearRangoFechas(
    String rangoFechas,
    Function(DateTime, DateTime) onParse,
  ) {
    final dates = rangoFechas.split(' - ');

    final fechaInicio = DateTime(
      int.parse(dates[0].split('/')[2]), // Año
      int.parse(dates[0].split('/')[1]), // Mes
      int.parse(dates[0].split('/')[0]), // Día
    );

    final fechaTermino = DateTime(
      int.parse(dates[1].split('/')[2]), // Año
      int.parse(dates[1].split('/')[1]), // Mes
      int.parse(dates[1].split('/')[0]), // Día
    );

    onParse(fechaInicio, fechaTermino);
  }
}
