import 'dart:developer';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.capacitacion.dart';
import 'package:sgem/shared/modules/capacitacion.carga.masiva.validado.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';

import '../../../../shared/modules/capacitacion.carga.masiva.excel.dart';

class CapacitacionCargaMasivaController extends GetxController {
  TextEditingController archivoController =
      TextEditingController(text: "Seleccione un archivo");

  var cargaMasivaExcel = <CapacitacionCargaMasivaExcel>[].obs;
  var cargaMasivaExcelGrabar = <CapacitacionCargaMasivaExcel>[].obs;
  var cargaMasivaResultadosValidados = <CapacitacionCargaMasivaValidado>[].obs;
  var cargaMasivaResultadosPaginados = <CapacitacionCargaMasivaValidado>[].obs;
  var registrosConErrores = <Map<String, dynamic>>[].obs;
  var capacitacionService = CapacitacionService();
  var rowsPerPage = 10.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalRecords = 0.obs;
  var correctRecords = 0.obs;

  var errorRecords = 0.obs;

  var archivoValidado = false.obs;
  var archivoSeleccionado = false.obs; // Estado de archivo seleccionado
  var registrosValidados = false.obs; // Estado de validación de registros
  var sinErrores = false.obs; // Estado de errores en registros

  void limpiar() {
    cargaMasivaResultadosPaginados.clear();
    cargaMasivaResultadosValidados.clear();
    cargaMasivaExcel.clear();
    registrosConErrores.clear();
    archivoSeleccionado.value = false;
    registrosValidados.value = false;
    sinErrores.value = false;
    archivoController.clear();
    totalRecords.value = 0;
    correctRecords.value = 0;
    errorRecords.value = 0;
    archivoValidado.value = false;
  }

  Future<void> cargarArchivo() async {
    limpiar();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.bytes != null) {
          Uint8List fileBytes = file.bytes!;
          String fileName = file.name;

          archivoController.text = fileName; // Muestra el nombre del archivo
          log('Documento adjuntado correctamente: $fileName');

          // Leer el archivo Excel
          var excel = Excel.decodeBytes(fileBytes);
          var sheet = excel.tables.keys.first;
          var rows = excel.tables[sheet]?.rows ?? [];

          // Procesar datos de Excel
          cargaMasivaExcel.clear();
          registrosConErrores.clear();
          log('Cantidad de registros excel: ${rows.length}');
          for (var i = 1; i < rows.length; i++) {
            // Ignorar la primera fila (cabecera)
            var row = rows[i];
            if (row.every((element) => element == null)) {
              continue;
            }
            Logger('Row').info('Row: $row');
            var registro = CapacitacionCargaMasivaExcel.fromExcelRow(row);
            if (registro.fechaInicio == null) {
              registrosConErrores.add({
                'row': i + 1,
                'error': 'Fecha de inicio no válida',
              });
              continue;
            }
            if (registro.fechaTermino == null) {
              registrosConErrores.add({
                'row': i + 1,
                'error': 'Fecha de término no válida',
              });
              continue;
            }
            log('Fecha inicio: ${registro.fechaInicio}');
            cargaMasivaExcel.add(registro);
          }

          log('Archivo Excel cargado con éxito');
          archivoSeleccionado.value = true;
        }
      } else {
        log('No se seleccionaron archivos');
      }
    } catch (e) {
      log('Error al adjuntar documentos: $e');
    }
  }

  Future<bool> confirmarCarga(BuildContext context) async {
    if (cargaMasivaExcel.isNotEmpty) {
      if (totalRecords == errorRecords) {
        mostrarErroresValidacion(
            context, ['No hay registros correctos para cargar.']);
        return false;
      }

      //final response = await capacitacionService.cargarMasiva(cargaMasivaList: cargaMasivaExcel);
      final response = await capacitacionService.cargarMasiva(
          cargaMasivaList: cargaMasivaExcelGrabar);

      cargaMasivaExcelGrabar.clear();

      if (response.success) {
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> previsualizarCarga(BuildContext context) async {
    if (cargaMasivaExcel.isNotEmpty) {
      // Muestra el mensaje de espera

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        barrierDismissible: true,
      );

      cargaMasivaExcelGrabar.clear();
      //final response = await capacitacionService.validarCargaMasiva(cargaMasivaList: cargaMasivaExcelGrabar);
      final response = await capacitacionService.validarCargaMasiva(
          cargaMasivaList: cargaMasivaExcel);
      if (response.success) {
        cargaMasivaResultadosValidados.value = response.data!;

        context.pop();
        goToPage(1);

        totalRecords.value = cargaMasivaResultadosValidados.length;
        totalPages.value = (totalRecords.value / rowsPerPage.value).ceil();

        // Contar los registros correctos y con errores
        int correctCount = 0;
        int errorCount = 0;

        for (var record in cargaMasivaResultadosValidados) {
          if (record.esValido) {
            correctCount++;
            cargaMasivaExcelGrabar.add(CapacitacionCargaMasivaExcel(
                codigo: record.codigo,
                dni: record.dni,
                nombres: record.nombres,
                guardia: record.guardia,
                entrenador: record.entrenador,
                codigoEntrenador: record.codigoEntrenador,
                nombreCapacitacion: record.nombreCapacitacion,
                categoria: record.categoria,
                empresa: record.empresa,
                fechaInicio: record.fechaInicio,
                fechaTermino: record.fechaTermino,
                horas: record.horas,
                notaPractica: record.notaPractica,
                notaTeorica: record.notaTeorica));
          } else {
            errorCount++;
          }
        }

        correctRecords.value = correctCount;
        errorRecords.value = errorCount;

        registrosValidados.value = true;
        if (errorRecords.value == 0) {
          sinErrores.value = true;
        }

        if (correctRecords.value > 0) {
          archivoValidado.value = true;
        }
      }
    } else {
      // Mostrar mensaje de error cuando no hay archivo seleccionado
      // context.snackbar(
      //   'Error',
      //   'No se ha seleccionado ningún archivo para cargar.',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      //   isDismissible: true,
      // );

      mostrarErroresValidacion(
          context, ['No se ha seleccionado ningún archivo para cargar.']);
    }

    // totalRecords.value = cargaMasivaResultados.length;
  }

  bool esConfirmacionValida() {
    return archivoValidado.value &&
        archivoSeleccionado.value &&
        registrosValidados.value &&
        //sinErrores.value;
        correctRecords.value > 0;
  }

  String generateExcelFileName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'CAPACITACIONES_MINA_$day$month$year$hour$minute$second';
  }

  Future<void> descargarPlantilla(BuildContext context) async {
    try {
      ByteData data = await rootBundle.load('assets/excel/Plantilla.xlsx');
      Uint8List bytes = data.buffer.asUint8List();
      // String fileName =  'CAPACITACIONES_MINA_${generateExcelFileName()}';
      await FileSaver.instance.saveFile(
          name: generateExcelFileName(),
          bytes: bytes,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel);

      context.snackbar(
        'Descarga exitosa',
        'Plantilla descargada con éxito',
      );
    } catch (e) {
      // context.snackbar('Error', 'Error al descargar la plantilla',
      //     snackPosition: SnackPosition.TOP,
      //     backgroundColor: Colors.redAccent,
      //     colorText: Colors.white);

      mostrarErroresValidacion(context, ['Error al descargar la plantilla']);
    }
  }

  void goToPage(int page) {
    currentPage.value = page;
    int start = (currentPage.value - 1) * rowsPerPage.value;
    int end = start + rowsPerPage.value;

    // Actualiza los resultados paginados
    cargaMasivaResultadosPaginados.value = cargaMasivaResultadosValidados
        .sublist(start, end.clamp(0, cargaMasivaResultadosValidados.length));
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      goToPage(currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      goToPage(currentPage.value - 1);
    }
  }

  void _mostrarMensajeGuardado(BuildContext context,
      {String title = "Los datos se guardaron \nsatisfactoriamente"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MensajeGuardadoWidget(
          title: title,
        );
      },
    );
  }

  void mostrarErroresValidacion(BuildContext context, List<String> errores) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MensajeValidacionWidget(errores: errores);
      },
    );
  }
}
