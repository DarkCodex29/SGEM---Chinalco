import 'dart:developer';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/api/api_fecha.dart';
import 'package:sgem/shared/dialogs/rango.fecha.dialog.dart';
import 'package:sgem/shared/models/fecha.dart';
import 'package:sgem/shared/modules/fechas.carga.masiva.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';

class FechasController extends GetxController {
  final fechaService = FechaService();
  TextEditingController rangoFechaController = TextEditingController();
  final GenericDropdownController anioController =
      Get.find<GenericDropdownController>();
  final GenericDropdownController guardiaController =
      Get.find<GenericDropdownController>();

  var archivosAdjuntos = <Map<String, dynamic>>[].obs;
  var archivo = Map<String, dynamic>().obs;

  final fechas = <Fecha>[].obs;
  var isExpanded = true.obs;
  var rowsPerPage = 10.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalRecords = 0.obs;

  var rowsPerPageMasive = 10.obs;
  var currentPageMasive = 1.obs;
  var totalPagesMasive = 1.obs;
  var totalRecordsMasive = 0.obs;

  DateTime? fechaInicio;
  DateTime? fechaTermino;

  var selectedAnioKey = OptionValue(key: 0, nombre: 'Todos').obs;
  var selectedGuardiaKey = OptionValue(key: 0, nombre: 'Todos').obs;

  PlatformFile? selectedFile;
  var registrosConErrores = <Map<String, dynamic>>[].obs;
  var cargaMasivaExcel = <FechaCargaMasiva>[].obs;

  var anios = <OptionValue>[].obs;
  var totalSuccess = 0.obs;
  var totalErrors = 0.obs;
  @override
  void onInit() async {
    super.onInit();

    // anioController.loadOptions('años', getAnios);

    /// .initializeDropdown('key');// .loadOptions('key', () => null)
    guardiaController.selectValueKey('guardiaFiltro', 0);
    await getAnios();

    await obtenerFechasPaginado(pageNumber: 1, pageSize: 10);
  }

  Future<List<OptionValue>> getAnios() async {
    anios.value = [];
    anios.add(OptionValue(key: 0, nombre: 'Todos'));

    final response = await fechaService.getFechasAnios();

    if (response != null && response.length > 0) {
      anios.addAll(response
          .map((e) => OptionValue(key: e.key, nombre: e.anio.toString())));
      final anioActual = response.where((element) => element.guardia.key == 1);
      if (anioActual.length > 0) {
        selectedAnioKey.value = OptionValue(
            key: anioActual.first.key,
            nombre: anioActual.first.anio.toString());
      }
    }

    return anios;
  }

  clearFilter() {
    final anioActual = anios
        .where((element) => element.nombre == DateTime.now().year.toString());
    if (anioActual.length > 0) {
      selectedAnioKey.value = OptionValue(
          key: anioActual.first.key, nombre: anioActual.first.nombre);
    }

    selectedGuardiaKey.value = OptionValue(key: 0, nombre: 'Todos');

    guardiaController.refresh();
    anioController.refresh();
    fechaInicio = null;
    fechaTermino = null;
    rangoFechaController.text = "";

    //rangoFechaController = TextEditingController(text: "");
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    DateTimeRange? rangoFechaSeleccionado;

    if (fechaInicio != null && fechaTermino != null) {
      rangoFechaSeleccionado = DateTimeRange(
        start: fechaInicio!,
        end: fechaTermino!,
      );
    }

    var seleccionado = await mostrarRangoFecha(context, rangoFechaSeleccionado);
    if (seleccionado != null) {
      rangoFechaController.text =
          '${DateFormat('dd/MM/yyyy').format(seleccionado.start)} - ${DateFormat('dd/MM/yyyy').format(seleccionado.end)}';
      fechaInicio = seleccionado.start;
      fechaTermino = seleccionado.end;
    }
  }

  Future<void> obtenerFechasPaginado({int? pageSize, int? pageNumber}) async {
    final response = await fechaService.getFechasPaginado(
        fechaInicio: fechaInicio,
        fechaFin: fechaTermino,
        inGuardia: selectedGuardiaKey.value.key == 0
            ? null
            : selectedGuardiaKey.value.key,
        anio: selectedAnioKey.value.key == 0
            ? null
            : int.parse(selectedAnioKey.value.nombre!),
        pageSize: rowsPerPage.value,
        pageNumber: currentPage.value);
    if (response.success && response.data != null) {
      var result = response.data as Map<String, dynamic>;

      var items = result['Items'] as List<Fecha>;
      fechas.assignAll(items);

      final tp = result['TotalPages'] as int;
      final tr = result['TotalRecords'] as int;
      currentPage.value = result['PageNumber'] as int;
      totalPages.value =
          tp; //result['TotalPages'] as int; //items.length <= 10 ? 1 : result['TotalPages'] as int;
      totalRecords.value =
          tr; //;items.length <= 10 ? items.length : result['TotalRecords'] as int;
      rowsPerPage.value = result['PageSize'] as int;
      // isExpanded.value = false;
    }
  }

  Future<void> adjuntarDocumentos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.bytes != null) {
            selectedFile = file;
            Uint8List fileBytes = file.bytes!;
            String fileName = file.name;

            archivosAdjuntos.add({
              'nombre': fileName,
              'bytes': fileBytes,
              'nuevo': true,
            });
            log('Documento adjuntado correctamente: $fileName');
          }
        }
      } else {
        log('No se seleccionaron archivos');
      }
    } catch (e) {
      log('Error al adjuntar documentos: $e');
    }
  }

  Future<void> eliminarArchivo(String nombreArchivo, int? key) async {
    archivosAdjuntos
        .removeWhere((archivo) => archivo['nombre'] == nombreArchivo);
    selectedFile = null;
    clearCronogramaForm();
    log('Archivo $nombreArchivo eliminado, cantidad eliminados: ${archivosAdjuntos.length}');
  }

  Future<void> descargarPlantilla(
    BuildContext context,
  ) async {
    try {
      final response = await fechaService.getFechasPaginado(
        fechaInicio: null,
        fechaFin: null,
        inGuardia: null,
        anio: null,
        pageSize: 10000,
        pageNumber: 1,
      );

      var result = response.data as Map<String, dynamic>;

      var items = result['Items'] as List<Fecha>;
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Plantilla');

      CellStyle headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      List<String> headers = ['GUARDIA', 'FECHA_INICIO', 'FECHA_FIN'];

      for (int i = 0; i < headers.length; i++) {
        var cell = excel.sheets['Plantilla']!
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;

        excel.sheets['Plantilla']!
            .setColumnWidth(i, headers[i].length.toDouble() + 5);
      }

      // final dateFormat = DateFormat('dd/MM/yyyy');

      for (int rowIndex = 0; rowIndex < items.length; rowIndex++) {
        var entrenamiento = items[rowIndex];
        List<CellValue> row = [
          TextCellValue(entrenamiento.guardia.nombre ?? ""),
          TextCellValue(
              DateFormat('dd/MM/yyyy').format(entrenamiento.fechaInicio) ?? ""),
          TextCellValue(
              DateFormat('dd/MM/yyyy').format(entrenamiento.fechaFin) ?? ""),
        ];

        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          var cell = excel.sheets['Plantilla']!.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, rowIndex: rowIndex + 1));
          cell.value = row[colIndex];
        }
      }

      var excelBytes = excel.encode();
      Uint8List uint8ListBytes = Uint8List.fromList(excelBytes!);

      DateTime now = DateTime.now();
      // Formatear fecha y hora
      String fecha = DateFormat('ddMMyy').format(now); // Formato: 040624
      String hora = DateFormat('HHmmss').format(now); // Formato: 113245

      // Generar la cadena
      String fileName = "CRONOGRAMA_MINA_${fecha}${hora}";

      await FileSaver.instance.saveFile(
          name: fileName,
          bytes: uint8ListBytes,
          ext: "xlsx",
          mimeType: MimeType.microsoftExcel);

      // await FileSaver.instance.saveFile(
      //     name: fileName,
      //     bytes: bytes,
      //     ext: 'xlsx',
      //     mimeType: MimeType.microsoftExcel);

      context.snackbar(
        'Descarga exitosa',
        'Plantilla descargada con éxito',
      );
    } catch (e) {
      context.snackbar(
        'Error',
        'Error al descargar la plantilla',
      );
    }
  }

  Future<bool> confirmarCarga() async {
    if (archivosAdjuntos.isNotEmpty) {
      // final response = await capacitacionService.cargarMasiva(
      //     cargaMasivaList: cargaMasivaExcel);

      // if (response.success) {
      //   return true;
      // }
      return false;
    }
    return false;
  }

  Future<void> previsualizarCarga(
    BuildContext context,
  ) async {
    if (selectedFile != null) {
      if (selectedFile!.bytes != null) {
        Uint8List fileBytes = selectedFile!.bytes!;
        String fileName = selectedFile!.name;

        log('Documento adjuntado correctamente: $fileName');

        // Leer el archivo Excel
        var excel = Excel.decodeBytes(fileBytes);
        var sheet = excel.tables.keys.first;
        var rows = excel.tables[sheet]?.rows ?? [];

        // Procesar datos de Excel
        cargaMasivaExcel.clear();

        var guardias = guardiaController.getOptions('guardiaFiltro');

        List<FechaCargaMasiva> lista = [];
        log('Cantidad de registros excel: ${rows.length}');
        for (var i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.every((element) => element == null)) {
            continue;
          }
          //Logger('Row').info('Row: $row');

          int anio = 0;
          var array = (row[1]?.value.toString() ?? '').split('/');
          if (array.length > 2) {
            anio = int.parse(array[2]);
          }

          DateTime? fechaInicio;
          DateTime? fechaFin;

          try {
            // Procesar fechaInicio
            if (row[1]?.value != null) {
              final esFechaInicio =
                  (row[1]?.value!.runtimeType == DateCellValue);
              print('Es fecha ${esFechaInicio}');
              if (esFechaInicio) {
                // La celda ya contiene un DateTime
                fechaInicio = DateTime.tryParse(
                    row[1]?.value.toString() ?? ''); //row[1]?.value s DateTime;
              } else {
                // La celda contiene una cadena
                fechaInicio = DateFormat("dd/MM/yyyy")
                    .parse(row[1]?.value.toString() ?? '');
              }
            }

            // Procesar fechaFin
            if (row[2]?.value != null) {
              if (row[2]?.value.runtimeType == DateCellValue) {
                // La celda ya contiene un DateTime
                fechaFin = DateTime.tryParse(row[2]?.value.toString() ??
                    ''); //row[2]?.value as DateTime;
              } else {
                // La celda c//if (row[2]?.value is String)ontiene una cadena
                fechaFin = DateFormat("dd/MM/yyyy")
                    .parse(row[2]?.value.toString() ?? '');
              }
            }
          } catch (e) {
            log('Error al parsear fechas en la fila $i: $e');
          }

          final existenGuardias = guardias
                  .where((element) =>
                      element.nombre == (row[0]?.value.toString() ?? ''))
                  .length >
              0;

          if (fechaInicio == null && fechaFin == null && !existenGuardias)
            continue;

          var registro = FechaCargaMasiva(
              anio: anio,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
              guardia: row[0]?.value.toString() ?? '',
              valido: true,
              index: i,
              esErrorFechaFin: false,
              esErrorFechaInicio: false,
              esErrorGuardia: false);

          if (!existenGuardias) {
            registro.esErrorGuardia = true;
            registro.valido = false;
          }

          // Validar registros
          if (registro.fechaInicio == null) {
            registro.valido = false;
            registro.esErrorFechaInicio = true;
            registro.errorFechaInicio = 'Fecha de inicio no válida';
            // registrosConErrores.add({
            //   'row': i + 1,
            //   'error': 'Fecha de inicio no válida',
            // });
          }
          if (registro.fechaFin == null) {
            registro.valido = false;
            registro.esErrorFechaFin = true;
            registro.errorFechaFin = 'Fecha de término no válida';
            // registrosConErrores.add({
            //   'row': i + 1,
            //   'error': 'Fecha de término no válida',
            // });
          }

          if (fechaInicio != null && fechaFin != null) {
            if (fechaInicio.isAfter(fechaFin)) {
              // La fecha de inicio es mayor a la fecha de fin
              registro.valido = false; // Marcar como no válido
              registro.esErrorFechaFin = true;
              registro.errorFechaFin =
                  'Fecha termino no puede ser menor a la fecha inicio.';
            }

            if (fechaInicio.year != fechaFin.year) {
              registro.valido = false; // Marcar como no válido
              registro.esErrorFechaFin = true;
              registro.errorFechaFin =
                  'La fecha de inicio y fecha de fin deben ser del mismo año.';
            }
          }
          log('Fecha inicio: ${registro.fechaInicio}');
          lista.add(registro);
        }

        if (lista.isNotEmpty) {
          totalRecords.value = lista.length;
          totalSuccess.value = lista.where((p0) => p0.valido).length;
          totalErrors.value = lista.where((p0) => !p0.valido).length;
          totalRecordsMasive.value = lista.length;
        }
        cargaMasivaExcel.assignAll(lista);
        log('Archivo Excel cargado con éxito ${lista.length}');
      }
    } else {
      // Mostrar mensaje de error cuando no hay archivo seleccionado
      context.snackbar(
        'Error',
        'No se ha seleccionado ningún archivo para cargar.',
      );
    }
  }

  void clearCronogramaForm() {
    // totalRecords.value = 0;
    totalSuccess.value = 0;
    totalErrors.value = 0;

    totalRecordsMasive.value = 0;
    cargaMasivaExcel.clear(); // = <FechaCargaMasiva>[].obs;

    archivosAdjuntos.clear();
  }

  Future<bool> grabarCronograma(BuildContext context) async {
    bool result = true;
    if (cargaMasivaExcel.length != 0) {
      List<Fecha> items = [];

      var guardias = guardiaController.getOptions('guardiaFiltro');

      cargaMasivaExcel.forEach((item) {
        if (item.valido) {
          items.add(
            Fecha(
                key: 0,
                fechaInicio: item.fechaInicio!,
                fechaFin: item.fechaFin!,
                guardia: OptionValue(
                    key: guardias
                        .where((element) => element.nombre == item.guardia)
                        .first
                        .key,
                    nombre: item.guardia),
                anio: item.fechaInicio!.year,
                fechaModificacion: DateTime.now(),
                usuarioModificacion: ''),
          );
        }
      });

      if (items.length > 0) {
        final response = await fechaService.registrarFecha(fechas: items);
        if (response.success) {
          //anios.clear();
          //selectedAnioKey.value = OptionValue(key: null, nombre: 'Todos');
          //  anioController.clear();
          //anioController.loadOptions('años', getAnios);
          await getAnios();

          _mostrarMensajeGuardado(context,
              title: 'Se realizó la carga de ${items.length} registros');
          result = true;
        } else {
          mostrarErroresValidacion(
              context, ['Se produjo un error al grabar los datos']);
          result = false;
        }
      } else {
        mostrarErroresValidacion(
            context, ['No hay registros correctos para cargar.']);
      }
    } else {
      result = false;
      // context.snackbar(
      //   'Error',
      //   'No se ha cargado ningún archivo.',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      //   isDismissible: true,
      // );
      mostrarErroresValidacion(
          context, ['No hay registros correctos para cargar.']);
    }

    return result;
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
