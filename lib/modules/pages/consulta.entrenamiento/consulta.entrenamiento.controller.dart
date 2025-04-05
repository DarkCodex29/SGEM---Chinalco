import 'dart:developer';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/shared/dialogs/rango.fecha.dialog.dart';
import 'package:sgem/shared/modules/entrenamiento.consulta.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class ConsultaEntrenamientoController extends GetxController {
  TextEditingController codigoMcpController = TextEditingController();
  TextEditingController rangoFechaController = TextEditingController();
  TextEditingController nombresController = TextEditingController();

  DateTime? fechaInicio;
  DateTime? fechaTermino;

  final entrenamientoService = EntrenamientoService();

  final isExpanded = true.obs;
  final entrenamientoResultados = <EntrenamientoConsulta>[].obs;

  final rowsPerPage = 10.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;

  final guardiaController = DropdownController();
  final estadoEntrenamientoController = DropdownController();
  final condicionController = DropdownController();
  final equipoController = DropdownController();
  final moduloController = DropdownController();

  @override
  void onInit() {
    super.onInit();
    buscarEntrenamientos(
      pageNumber: currentPage.value,
      pageSize: rowsPerPage.value,
    );
  }

  Future<void> buscarEntrenamientos({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final codigoMcp =
        codigoMcpController.text.isEmpty ? null : codigoMcpController.text;
    final nombres =
        nombresController.text.isEmpty ? null : nombresController.text;
    try {
      //log('${}');
      final response =
          await entrenamientoService.consultarEntrenamientoPaginado(
        codigoMcp: codigoMcp,
        inEquipo: equipoController.value,
        inModulo: moduloController.value,
        inGuardia: guardiaController.value,
        inEstadoEntrenamiento: estadoEntrenamientoController.value,
        inCondicion: condicionController.value,
        fechaInicio: fechaInicio,
        fechaTermino: fechaTermino,
        nombres: nombres,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      log('Termino consulta');
      if (response.success && response.data != null) {
        try {
          final result = response.data!;
          log('Respuesta recibida correctamente $result');

          final items = result['Items'] as List<EntrenamientoConsulta>;
          log('Items obtenidos: $items');

          entrenamientoResultados.assignAll(items);

          currentPage.value = result['PageNumber'] as int;
          totalPages.value = result['TotalPages'] as int;
          totalRecords.value = result['TotalRecords'] as int;
          rowsPerPage.value = result['PageSize'] as int;
          isExpanded.value = false;

          log('Resultados obtenidos: ${entrenamientoResultados.length}');
        } catch (e) {
          log('Error al procesar la respuesta: $e');
        }
      } else {
        log('Error en la búsqueda: ${response.message}');
      }
    } catch (e) {
      log('Error en la búsqueda 2: $e');
    }
  }

  Future<void> downloadExcel() async {
    final excel = Excel.createExcel()..rename('Sheet1', 'Entrenamiento');

    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final headers = <String>[
      'CODIGO_MCP',
      'NOMBRES Y APELLIDOS',
      'GUARDIA',
      'ESTADO_ENTRENAMIENTO',
      'ESTADO_AVANCE',
      ' CONDICIÓN',
      ' EQUIPO',
      'FECHA_INICIO',
      'FECHA_FIN',
      'ENTRENADOR_RESPONSABLE',
      'NOTA_TEÓRICA',
      'NOTA_PRÁCTICA',
      'HORAS_ACUMULADAS',
      'HORAS_OPERATIVAS_ACUMULADAS',
    ];

    final codigoMcp =
        codigoMcpController.text.isEmpty ? null : codigoMcpController.text;
    final nombres =
        nombresController.text.isEmpty ? null : nombresController.text;

    final response = await entrenamientoService.consultarEntrenamientoPaginado(
      pageSize: 1000,
      pageNumber: 1,
      codigoMcp: codigoMcp,
      inEquipo: equipoController.value,
      inModulo: moduloController.value,
      inGuardia: guardiaController.value,
      inEstadoEntrenamiento: estadoEntrenamientoController.value,
      inCondicion: condicionController.value,
      fechaInicio: fechaInicio,
      fechaTermino: fechaTermino,
      nombres: nombres,
    );

    if (!response.success || response.data == null) {
      return;
    }

    final entrenamientoResultados =
        response.data!['Items'] as List<EntrenamientoConsulta>;

    for (var i = 0; i < headers.length; i++) {
      excel.sheets['Entrenamiento']!
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;

      excel.sheets['Entrenamiento']!
          .setColumnWidth(i, headers[i].length.toDouble() + 5);
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var rowIndex = 0;
        rowIndex < entrenamientoResultados.length;
        rowIndex++) {
      final entrenamiento = entrenamientoResultados[rowIndex];
      final row = <CellValue>[
        TextCellValue(entrenamiento.codigoMcp),
        TextCellValue(entrenamiento.nombreCompleto),
        TextCellValue(entrenamiento.guardia.nombre!),
        TextCellValue(entrenamiento.estadoEntrenamiento.nombre!),
        TextCellValue(entrenamiento.modulo.nombre!),
        TextCellValue(entrenamiento.condicion.nombre!),
        TextCellValue(entrenamiento.equipo.nombre!),
        if (entrenamiento.fechaInicio != null)
          TextCellValue(dateFormat.format(entrenamiento.fechaInicio!))
        else
          TextCellValue(''),
        if (entrenamiento.fechaTermino != null)
          TextCellValue(dateFormat.format(entrenamiento.fechaTermino!))
        else
          TextCellValue(''),
        TextCellValue(entrenamiento.entrenador.nombre!),
        TextCellValue(entrenamiento.notaTeorica.toString()),
        TextCellValue(entrenamiento.notaPractica.toString()),
        TextCellValue(entrenamiento.horasAcumuladas.toString()),
        TextCellValue(entrenamiento.horasOperativasAcumuladas.toString()),
      ];

      for (var colIndex = 0; colIndex < row.length; colIndex++) {
        excel.sheets['Entrenamiento']!
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: colIndex,
                rowIndex: rowIndex + 1,
              ),
            )
            .value = row[colIndex];

        final contentWidth = row[colIndex].toString().length.toDouble();
        if (contentWidth >
            excel.sheets['Entrenamiento']!.getColumnWidth(colIndex)) {
          excel.sheets['Entrenamiento']!
              .setColumnWidth(colIndex, contentWidth + 5);
        }
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

  String generateExcelFileName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'ENTRENAMIENTOS_MINA_$day$month$year$hour$minute$second';
  }

  void resetControllers() {
    codigoMcpController.clear();
    rangoFechaController.clear();
    fechaInicio = null;
    fechaTermino = null;
    nombresController.clear();
    equipoController.clear();
    moduloController.clear();
    guardiaController.clear();
    estadoEntrenamientoController.clear();
    condicionController.clear();
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    DateTimeRange? rangoFechaSeleccionado;

    if (fechaInicio != null && fechaTermino != null) {
      rangoFechaSeleccionado = DateTimeRange(
        start: fechaInicio!,
        end: fechaTermino!,
      );
    }

    final seleccionado =
        await mostrarRangoFecha(context, rangoFechaSeleccionado);
    if (seleccionado != null) {
      rangoFechaController.text =
          '${DateFormat('dd/MM/yyyy').format(seleccionado.start)} '
          '- ${DateFormat('dd/MM/yyyy').format(seleccionado.end)}';
      fechaInicio = seleccionado.start;
      fechaTermino = seleccionado.end;
    }
  }
}
