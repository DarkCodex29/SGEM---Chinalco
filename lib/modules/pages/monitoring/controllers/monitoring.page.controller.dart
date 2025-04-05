import 'dart:developer';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/config/api/api.modulo.maestro.dart';
import 'package:sgem/config/api/api.monitoring.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/config/constants/estado.entrenamiento.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/maestro.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/modulo.maestro.dart';
import 'package:sgem/shared/modules/monitoring.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';

enum MonitoringSearchScreen {
  none,
  newMonitoring,
  editMonitoring,
  trainingForm,
  viewMonitoring,
  carnetMonitoring,
  diplomaMonitoring,
  certificadoMonitoring,
  actualizacionMasiva
}

extension MonitoringSearchScreenExtension on MonitoringSearchScreen {
  String description() {
    switch (this) {
      case MonitoringSearchScreen.none:
        return "";
      case MonitoringSearchScreen.newMonitoring:
        return "Nuevo Monitoring a Entrenar";
      case MonitoringSearchScreen.editMonitoring:
        return "Editar Monitoring";
      case MonitoringSearchScreen.trainingForm:
        return "Búsqueda de entrenamiento de Monitoring";
      case MonitoringSearchScreen.viewMonitoring:
        return "Visualizar";
      case MonitoringSearchScreen.carnetMonitoring:
        return "Carnet del Monitoring";
      case MonitoringSearchScreen.actualizacionMasiva:
        return "Actualizacion Masiva";
      default:
        return "Entrenamientos";
    }
  }
}

class MonitoringSearchController extends GetxController {
  final PersonalService personalService = PersonalService();
  final entrenamientoService = EntrenamientoService();
  final maestroDetalleService = MaestroDetalleService();
  final moduloService = ModuloMaestroService();
  final monitoringService = MonitoringService();
  TextEditingController codigoMCPController = TextEditingController();
  TextEditingController documentoIdentidadController = TextEditingController();
  TextEditingController nombresController = TextEditingController();
  TextEditingController apellidosMaternoController = TextEditingController();
  TextEditingController apellidosPaternoController = TextEditingController();
  TextEditingController rangoFechaController = TextEditingController();

  final Logger _logger = Logger('MonitoringSearchController');

  DateTime? fechaInicio;
  DateTime? fechaTermino;
  var screen = MonitoringSearchScreen.none.obs;
  var isExpanded = true.obs;
  var rowsPerPage = 10.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalRecords = 0.obs;
  RxList<MaestroDetalle> guardiaOptions = <MaestroDetalle>[].obs;
  var monitoringAll = <Monitoring>[].obs;

  RxList<ModuloMaestro> moduloOpciones = <ModuloMaestro>[].obs;
  RxList<MaestroDetalle> guardiaOpciones = <MaestroDetalle>[].obs;
  RxList<MaestroDetalle> equipoOpciones = <MaestroDetalle>[].obs;

  RxList<MaestroDetalle> estadoEntrenamientoOpciones = <MaestroDetalle>[].obs;

  RxList<MaestroDetalle> condicionOpciones = <MaestroDetalle>[].obs;
  RxList<Personal> entrenadores = <Personal>[].obs;

  RxList<MaestroDetalle> equipoOpcionesForm = <MaestroDetalle>[].obs;
  RxList<MaestroDetalle> estadoEntrenamientoOpcionesForm =
      <MaestroDetalle>[].obs;

  RxList<EntrenamientoModulo> listaEntrenamientosPersonal =
      <EntrenamientoModulo>[].obs;
  //   List<EntrenamientoModulo>

  var selectedEquipoKey = RxnInt();
  var selectedEntrenadorKey = RxnInt();
  var selectedModuloKey = RxnInt();
  var selectedGuardiaKey = RxnInt();
  var selectedEstadoEntrenamientoKey = RxnInt();
  var selectedCondicionKey = RxnInt();

  var formWithUserValid = RxnBool();

  @override
  void onInit() {
    cargarModulo();
    cargarEquipo();
    cargarGuardia();
    cargarEstadoEntrenamiento(false, '');
    cargarCondicion();
    cargarEntrenadores();
    searchMonitoring(
        pageNumber: currentPage.value, pageSize: rowsPerPage.value);
    super.onInit();
  }

  clearFilter() {
    codigoMCPController = TextEditingController(text: "");
    documentoIdentidadController = TextEditingController(text: "");
    nombresController = TextEditingController(text: "");
    apellidosMaternoController = TextEditingController(text: "");
    apellidosPaternoController = TextEditingController(text: "");
    rangoFechaController = TextEditingController(text: "");
    fechaInicio = null;
    fechaTermino = null;
    selectedEquipoKey.value = null;
    selectedEntrenadorKey.value = null;
    selectedModuloKey.value = null;
    selectedGuardiaKey.value = null;
    selectedEstadoEntrenamientoKey.value = null;
    selectedCondicionKey.value = null;
  }

  Future<void> searchMonitoring({int pageNumber = 1, int pageSize = 10}) async {
    String? codigoMcp =
        codigoMCPController.text.isEmpty ? null : codigoMCPController.text;
    String? apellidoMaterno = apellidosMaternoController.text.isEmpty
        ? null
        : apellidosMaternoController.text;
    String? apllidoPaterno = apellidosPaternoController.text.isEmpty
        ? null
        : apellidosPaternoController.text;
    String? nombres =
        nombresController.text.isEmpty ? null : nombresController.text;

    try {
      var response = await monitoringService.queryMonitoringPaginated(
          codigoMcp: codigoMcp,
          apellidoMaterno: apellidoMaterno,
          apellidoPaterno: apllidoPaterno,
          nombres: nombres,
          inEntrenador: selectedEntrenadorKey.value,
          inCondicion: selectedCondicionKey.value,
          inEquipo: selectedEquipoKey.value,
          inEstadoEntrenamiento: selectedEstadoEntrenamientoKey.value,
          inGuardia: selectedGuardiaKey.value,
          pageNumber: pageNumber,
          pageSize: pageSize,
          fechaInicio: fechaInicio,
          fechaTermino: fechaTermino);

      if (response.success && response.data != null) {
        var result = response.data as Map<String, dynamic>;

        var items = result['Items'] as List<Monitoring>;
        monitoringAll.assignAll(items);
        currentPage.value = result['PageNumber'] as int;
        totalPages.value = result['TotalPages'] as int;
        totalRecords.value = result['TotalRecords'] as int;
        rowsPerPage.value = result['PageSize'] as int;
        isExpanded.value = false;
      }
    } catch (e) {
      _logger.info('Error en la búsqueda2: $e');
    }
  }

  Future<void> cargarEntrenadores() async {
    try {
      var response = await personalService.listarEntrenadores();

      if (response.success && response.data != null) {
        entrenadores.assignAll(response.data!);
      }
    } catch (e) {
      _logger.info('Error cargando la data de entrenadores : $e');
    }
  }

  Future<void> cargarEstadoEntrenamiento(
      bool isSearchPerson, String personCode) async {
    try {
      var response = await maestroDetalleService.listarMaestroDetallePorMaestro(
          4); //Catalogo de Estado de Entrenamiento

      if (response.success && response.data != null) {
        estadoEntrenamientoOpciones.assignAll(response.data!);

        _logger.info(
            'Estado entrenamiento opciones cargadas correctamente: $estadoEntrenamientoOpciones');
      } else {
        _logger.info('Error: ${response.message}');
      }
    } catch (e) {
      _logger
          .info('Error cargando la data de estado entrenamiento maestro: $e');
    }
  }

  Future<void> cargarCondicion() async {
    try {
      var response = await maestroDetalleService.listarMaestroDetallePorMaestro(
          6); //Catalogo de condicion de entrenamiento

      if (response.success && response.data != null) {
        condicionOpciones.assignAll(response.data!);

        _logger.info(
            'Condicion de entrenamiento opciones cargadas correctamente: $estadoEntrenamientoOpciones');
      } else {
        _logger.info('Error: ${response.message}');
      }
    } catch (e) {
      _logger.info(
          'Error cargando la data de condicion de entrenamiento maestro: $e');
    }
  }

  Future<void> cargarModulo() async {
    try {
      var response = await moduloService.listarMaestros();

      if (response.success && response.data != null) {
        moduloOpciones.assignAll(response.data!);

        _logger.info(
            'Modulos maestro opciones cargadas correctamente: $guardiaOpciones');
      } else {
        _logger.info('Error: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error cargando la data de Modulos maestro: $e');
    }
  }

  Future<void> cargarEquipo() async {
    try {
      var response = await maestroDetalleService
          .listarMaestroDetallePorMaestro(5); //Maestro de Equipos

      if (response.success && response.data != null) {
        equipoOpciones.assignAll(response.data!);

        _logger
            .info('Equipos opciones cargadas correctamente: $equipoOpciones');
      } else {
        _logger.info('Error: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error cargando la data de guardia maestro: $e');
    }
  }

  Future<void> cargarGuardia() async {
    try {
      var response =
          await maestroDetalleService.listarMaestroDetallePorMaestro(2);

      if (response.success && response.data != null) {
        guardiaOpciones.assignAll(response.data!);

        _logger
            .info('Guardia opciones cargadas correctamente: $guardiaOpciones');
      } else {
        _logger.info('Error: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error cargando la data de guardia maestro: $e');
    }
  }

  Future<void> downloadExcel() async {
    String? codigoMcp =
        codigoMCPController.text.isEmpty ? null : codigoMCPController.text;
    String? apellidoMaterno = apellidosMaternoController.text.isEmpty
        ? null
        : apellidosMaternoController.text;
    String? apllidoPaterno = apellidosPaternoController.text.isEmpty
        ? null
        : apellidosPaternoController.text;
    String? nombres =
        nombresController.text.isEmpty ? null : nombresController.text;

    var response = await monitoringService.queryMonitoringPaginated(
        isPaginate: false,
        codigoMcp: codigoMcp,
        apellidoMaterno: apellidoMaterno,
        apellidoPaterno: apllidoPaterno,
        nombres: nombres,
        inEntrenador: selectedEntrenadorKey.value,
        inCondicion: selectedCondicionKey.value,
        inEquipo: selectedEquipoKey.value,
        inEstadoEntrenamiento: selectedEstadoEntrenamientoKey.value,
        inGuardia: selectedGuardiaKey.value,
        fechaInicio: fechaInicio,
        fechaTermino: fechaTermino);
    if (response.success && response.data != null) {
      var result = response.data as Map<String, dynamic>;

      var items = result['Items'] as List<Monitoring>;
      var excel = Excel.createExcel();
      excel.rename('Sheet1', 'Monitoreo');

      CellStyle headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.blue,
        fontColorHex: ExcelColor.white,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      List<String> headers = [
        'CÓDIGO_MCP',
        'APELLIDO_PATERNO',
        'APELLIDO_MATERNO',
        'NOMBRES',
        'GUARDIA',
        'ESTADO_ENTRENAMIENTO',
        'EQUIPO',
        'HORAS',
        'ENTRENADOR_RESPONSABLE',
        'CONDICIÓN_MONITOREO',
        'FECHA_REAL_DE_MONITOREO',
        'FECHA_PROXIMO_MONITOREO',
      ];

      for (int i = 0; i < headers.length; i++) {
        var cell = excel.sheets['Monitoreo']!
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;

        excel.sheets['Monitoreo']!
            .setColumnWidth(i, headers[i].length.toDouble() + 5);
      }

      // final dateFormat = DateFormat('dd/MM/yyyy');

      for (int rowIndex = 0; rowIndex < items.length; rowIndex++) {
        var entrenamiento = items[rowIndex];
        List<CellValue> row = [
          TextCellValue(entrenamiento.codigoMcp ?? ""),
          TextCellValue(entrenamiento.apellidoPaterno ?? ""),
          TextCellValue(entrenamiento.apellidoMaterno ?? ""),
          TextCellValue(
              "${entrenamiento.primerNombre} ${entrenamiento.segundoNombre}"),
          TextCellValue(entrenamiento.guardia?.nombre ?? ""),
          TextCellValue(entrenamiento.estadoEntrenamiento!.nombre!),
          TextCellValue(entrenamiento.equipo?.nombre ?? ""),
          TextCellValue(entrenamiento.totalHoras.toString()),
          TextCellValue(entrenamiento.entrenador?.nombre ?? ""),
          TextCellValue(entrenamiento.condicion?.nombre ?? ""),
          TextCellValue(DateFormat('dd/MM/yyyy')
              .format(entrenamiento.fechaRealMonitoreo!)),
          TextCellValue(entrenamiento.fechaProximoMonitoreo == null
              ? ''
              : DateFormat('dd/MM/yyyy')
                  .format(entrenamiento.fechaProximoMonitoreo!)),
        ];

        for (int colIndex = 0; colIndex < row.length; colIndex++) {
          var cell = excel.sheets['Monitoreo']!.cell(CellIndex.indexByColumnRow(
              columnIndex: colIndex, rowIndex: rowIndex + 1));
          cell.value = row[colIndex];

          // double contentWidth = row[colIndex].toString().length.toDouble();
          // if (contentWidth >
          //     excel.sheets['Monitoreo']!.getColumnWidth(colIndex)) {
          //   excel.sheets['Monitoreos']!
          //       .setColumnWidth(colIndex, contentWidth + 5);
          // }
        }
      }

      var excelBytes = excel.encode();
      Uint8List uint8ListBytes = Uint8List.fromList(excelBytes!);

      String fileName = generateExcelFileName();
      await FileSaver.instance.saveFile(
          name: fileName,
          bytes: uint8ListBytes,
          ext: "xlsx",
          mimeType: MimeType.microsoftExcel);
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

    return 'MONITOREOS_MINA_$day$month$year$hour$minute$second';
  }

  Future<List<EntrenamientoModulo>?> listarEntrenamientosPorPersonaId(
      int personaId) async {
    final entrenamientos =
        await entrenamientoService.listarEntrenamientoPorPersona(personaId);
    // final response =
    //     await entrenamientoService.listarEntrenamientoPorPersona(0);

    if (entrenamientos.success) {
      final trainingList = entrenamientos.data!
          .map((json) => EntrenamientoModulo.fromJson(json))
          .toList();

      return trainingList;
    }

    return null;
  }

  Future<bool> listarEstadoEntrenamiento(
      BuildContext context, String codigoMcp) async {
    //estadoEntrenamientoOpcionesForm = <MaestroDetalle>[].obs;
    var respuesta = false;
    var responsePersona =
        await personalService.listarPersonalEntrenamientoPaginado(
      codigoMcp: codigoMcp,
      numeroDocumento: null,
      nombres: null,
      apellidos: null,
      inGuardia: null,
      inEstado: null,
      pageSize: 10,
      pageNumber: 1,
    );

    if (responsePersona.success) {
      var result = responsePersona.data as Map<String, dynamic>;
      _logger.info('Respuesta recibida correctamente: $result');

      var items = result['Items'] as List<Personal>;
      _logger.info('Items obtenidos: $items');
      if (items.length > 0) {
        var persona = items.first;

        var trainingList = await listarEntrenamientosPorPersonaId(persona.id);
        if (trainingList == null) {
          mostrarErroresValidacion(context,
              ['No se encontraron entrenamientos para el código ingresado.']);

          return false;
          //resetInfoPerson();
        } else {
          listaEntrenamientosPersonal.assignAll(trainingList);

          var ids = [];
          trainingList
              .where((element) => element.key != EstadoEntrenamiento.paralizado)
              .forEach((element) {
            ids.add(element.estadoEntrenamiento!.key);
          });

          final listaEstadoEntrenamiento = estadoEntrenamientoOpciones.where(
              (p0) =>
                  ids.contains(p0.key) &&
                  p0.key != EstadoEntrenamiento.paralizado);
          _logger.info(
              'listaEstadoEntrenamiento ${listaEstadoEntrenamiento.length}');
          estadoEntrenamientoOpcionesForm.assignAll(listaEstadoEntrenamiento);

          _logger.info(
              'estadoEntrenamientoOpcionesForm ${estadoEntrenamientoOpcionesForm.length}');

          return true;
        }
      }
    }

    return respuesta;
  }

  Future<void> listarEstadoEntrenamientoPorId(
      BuildContext context, String codigoMcp, entrenamientoId) async {
    //estadoEntrenamientoOpcionesForm = <MaestroDetalle>[].obs;
    //  final response =
    //       await entrenamientoService.listarEntrenamientoPorPersona(personId);
    await listarEstadoEntrenamiento(context, codigoMcp);

    await listarEquipoEntrenamiento(entrenamientoId);
  }

  Future<void> listarEquipoEntrenamiento(int entrenamientoId) async {
    try {
      final listaEntrenamientoTmp = listaEntrenamientosPersonal;

      _logger.info('listaEntrenamientoTmp ${listaEntrenamientoTmp.length}');

      final equipos = listaEntrenamientoTmp.map(
        (entrenamient) => MaestroDetalle(
          key: entrenamient.equipo!.key,
          maestro: MaestroBasico(key: 0, nombre: 'nombre'),
          valor: entrenamient.equipo!.nombre,
          fechaRegistro: DateTime.now(),
          activo: 'SI',
        ),
      );

      equipoOpcionesForm.assignAll(equipos);
      _logger.info('equipoOpcionesForm ${equipoOpcionesForm.length}');
    } catch (error, stackTrace) {
      _logger.severe(
        'Error cargando la data de equipo entrenamiento',
        error,
        stackTrace,
      );
    }
  }

  void limpiarListasRegistroEdicion() {
    estadoEntrenamientoOpcionesForm = <MaestroDetalle>[].obs;
  }

  void limpiarListasEquiposRegistroEdicion() {
    equipoOpcionesForm = <MaestroDetalle>[].obs;
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
