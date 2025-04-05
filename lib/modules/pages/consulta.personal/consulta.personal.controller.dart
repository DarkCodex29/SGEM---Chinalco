import 'dart:developer';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import '../../../config/api/api.maestro.detail.dart';
import '../../../config/api/api.personal.dart';
import '../../../shared/modules/personal.dart';
import '../../../shared/widgets/dropDown/generic.dropdown.controller.dart';

enum PersonalSearchScreen {
  none,
  newPersonal,
  editPersonal,
  trainingForm,
  viewPersonal,
  carnetPersonal,
  diplomaPersonal,
  certificadoPersonal,
  actualizacionMasiva
}

extension PersonalSearchScreenExtension on PersonalSearchScreen {
  String descripcion() {
    switch (this) {
      case PersonalSearchScreen.none:
        return "Búsqueda de entrenamiento de personal";
      case PersonalSearchScreen.newPersonal:
        return "Agregar personal a entrenar";
      case PersonalSearchScreen.editPersonal:
        return "Editar personal";
      case PersonalSearchScreen.trainingForm:
        return "Búsqueda de entrenamiento de personal";
      case PersonalSearchScreen.viewPersonal:
        return "Visualizar personal";
      case PersonalSearchScreen.carnetPersonal:
        return "Carnet del personal";
      case PersonalSearchScreen.actualizacionMasiva:
        return "Actualización masiva";
      default:
        return "Entrenamientos";
    }
  }
}

class PersonalSearchController extends GetxController {
  PersonalSearchController(this.context);
  final BuildContext context;

  final codigoMCPController = TextEditingController();
  final documentoIdentidadController = TextEditingController();
  final nombresController = TextEditingController();
  final apellidosController = TextEditingController();
  final expansionController = ExpansionTileController();

  final personalService = PersonalService();
  final maestroDetalleService = MaestroDetalleService();

  final isExpanded = true.obs;
  final screen = PersonalSearchScreen.none.obs;

  final personalResults = <Personal>[].obs;
  final selectedPersonal = Rxn<Personal>();

  final rowsPerPage = 10.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;

  final isLoadingGuardia = false.obs;
  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();

  Logger _logger = Logger('PersonalSearchController');

  @override
  void onInit() {
    super.onInit();
    dropdownController.selectValueKey('estado', 0);
    dropdownController.selectValueKey('guardiaFiltro', 0);
    searchPersonal(pageNumber: currentPage.value, pageSize: rowsPerPage.value);
  }

  Future<Uint8List?> loadPersonalPhoto(int idOrigen) async {
    try {
      final photoResponse =
          await personalService.obtenerFotoPorCodigoOrigen(idOrigen);
      if (photoResponse.success && photoResponse.data != null) {
        return photoResponse.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> searchPersonal({int pageNumber = 1, int pageSize = 10}) async {
    final codigoMcp =
        codigoMCPController.text.isEmpty ? null : codigoMCPController.text;
    final numeroDocumento = documentoIdentidadController.text.isEmpty
        ? null
        : documentoIdentidadController.text;
    final nombres =
        nombresController.text.isEmpty ? null : nombresController.text;
    final apellidos =
        apellidosController.text.isEmpty ? null : apellidosController.text;

    try {
      final response =
          await personalService.listarPersonalEntrenamientoPaginado(
        codigoMcp: codigoMcp,
        numeroDocumento: numeroDocumento,
        nombres: nombres,
        apellidos: apellidos,
        inGuardia:
            dropdownController.getSelectedValue('guardiaFiltro')?.key == 0
                ? null
                : dropdownController.getSelectedValue('guardiaFiltro')?.key,
        inEstado: dropdownController.getSelectedValue('estado')?.key == 0
            ? null
            : dropdownController.getSelectedValue('estado')?.key,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );

      if (!response.success || response.data == null) {
        return MensajeValidacionWidget.single(
          response.message ?? 'Error al traer los datos de personal',
        ).show(context);
      }

      final result = response.data!;
      _logger.info('Respuesta recibida correctamente');

      final items = result['Items'] as List<Personal>;
      _logger.info('Items obtenidos: ${items.length}');

      personalResults.assignAll(items);

      currentPage.value = result['PageNumber'] as int;
      totalPages.value = result['TotalPages'] as int;
      totalRecords.value = result['TotalRecords'] as int;
      rowsPerPage.value = result['PageSize'] as int;
      isExpanded.value = false;

      _logger.info('Resultados obtenidos: ${personalResults.length}');
    } catch (error, stackTrace) {
      _logger.severe('Error en la búsqueda', error, stackTrace);
    }
  }

  Future<void> downloadExcel() async {
    final excel = Excel.createExcel()..rename('Sheet1', 'Personal');

    final headerStyle = CellStyle(
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    final headers = <String>[
      'DNI',
      'CÓDIGO',
      'APELLIDO PATERNO',
      'APELLIDO MATERNO',
      'NOMBRES',
      'GUARDIA',
      'PUESTO TRABAJO',
      'GERENCIA',
      'ÁREA',
      'FECHA INGRESO',
      'FECHA INGRESO MINA',
      'CÓDIGO LICENCIA',
      'CATEGORÍA LICENCIA',
      'FECHA REVALIDACIÓN',
      'RESTRICCIONES'
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = excel.sheets['Personal']!
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;

      excel.sheets['Personal']!
          .setColumnWidth(i, headers[i].length.toDouble() + 5);
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var rowIndex = 0; rowIndex < personalResults.length; rowIndex++) {
      final personal = personalResults[rowIndex];
      final row = <CellValue>[
        TextCellValue(personal.numeroDocumento!),
        TextCellValue(personal.codigoMcp!),
        TextCellValue(personal.apellidoPaterno!),
        TextCellValue(personal.apellidoMaterno!),
        TextCellValue('${personal.primerNombre} ${personal.segundoNombre}'),
        TextCellValue(personal.guardia!.nombre!),
        TextCellValue(personal.cargo!.nombre!),
        TextCellValue(personal.gerencia!),
        TextCellValue(personal.area!),
        personal.fechaIngreso != null
            ? TextCellValue(dateFormat.format(personal.fechaIngreso!))
            : TextCellValue(''),
        personal.fechaIngresoMina != null
            ? TextCellValue(dateFormat.format(personal.fechaIngresoMina!))
            : TextCellValue(''),
        TextCellValue(personal.licenciaConducir!),
        //TextCellValue(personal.licenciaCategoria!),
        TextCellValue(personal.licenciaCategoria!.nombre!),
        personal.fechaRevalidacion != null
            ? TextCellValue(dateFormat.format(personal.fechaRevalidacion!))
            : TextCellValue(''),
        TextCellValue(personal.restricciones!),
      ];

      for (var colIndex = 0; colIndex < row.length; colIndex++) {
        final cell = excel.sheets['Personal']!.cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex, rowIndex: rowIndex + 1));
        cell.value = row[colIndex];

        final contentWidth = row[colIndex].toString().length.toDouble();
        if (contentWidth > excel.sheets['Personal']!.getColumnWidth(colIndex)) {
          excel.sheets['Personal']!.setColumnWidth(colIndex, contentWidth + 5);
        }
      }
    }

    final excelBytes = excel.encode();
    final uint8ListBytes = Uint8List.fromList(excelBytes!);

    final fileName = generateExcelFileName();
    await FileSaver.instance.saveFile(
        name: fileName,
        bytes: uint8ListBytes,
        ext: "xlsx",
        mimeType: MimeType.microsoftExcel);
  }

  String generateExcelFileName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString().substring(2);
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    return 'PERSONAL_MINA_$day$month$year$hour$minute$second';
  }

  void resetControllers() {
    codigoMCPController.clear();
    documentoIdentidadController.clear();
    dropdownController.resetAllSelections();
    nombresController.clear();
    apellidosController.clear();
    dropdownController.selectValueKey('estado', 0);
    dropdownController.selectValueKey('guardiaFiltro', 0);
  }

  void showNewPersonal() {
    selectedPersonal.value = Personal(
      key: 0,
      tipoPersona: "",
      inPersonalOrigen: 0,
      licenciaConducir: "",
      operacionMina: "",
      zonaPlataforma: "",
      restricciones: "",
      usuarioRegistro: "",
      usuarioModifica: "",
      codigoMcp: "",
      nombreCompleto: "",
      cargo: OptionValue(key: 0, nombre: ""),
      numeroDocumento: "",
      guardia: OptionValue(key: 0, nombre: ""),
      estado: OptionValue(key: 0, nombre: ""),
      eliminado: "",
      motivoElimina: "",
      usuarioElimina: "",
      apellidoPaterno: "",
      apellidoMaterno: "",
      primerNombre: "",
      segundoNombre: "",
      fechaIngreso: null,
      //licenciaCategoria: "",
      licenciaCategoria: OptionValue(key: 0, nombre: ""),
      fechaRevalidacion: null,
      gerencia: "",
      area: "",
    );

    screen.value = PersonalSearchScreen.newPersonal;
  }

  void showEditPersonal(Personal personal) {
    selectedPersonal.value = personal;

    screen.value = PersonalSearchScreen.editPersonal;
  }

  void showViewPersonal(Personal personal) {
    selectedPersonal.value = personal;
    screen.value = PersonalSearchScreen.viewPersonal;
  }

  void hideForms() {
    screen.value = PersonalSearchScreen.none;
  }

  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
  }

  void showTraining(Personal? personal) {
    selectedPersonal.value = personal;
    screen.value = PersonalSearchScreen.trainingForm;
  }

  void showActualizacionMasiva() {
    screen.value = PersonalSearchScreen.actualizacionMasiva;
  }

  void showCarnet(Personal personal) {
    selectedPersonal.value = personal;
    screen.value = PersonalSearchScreen.carnetPersonal;
  }

  void showDiploma() {
    screen.value = PersonalSearchScreen.diplomaPersonal;
  }

  void showCertificado() {
    screen.value = PersonalSearchScreen.certificadoPersonal;
  }

  Future<void> showPersonal(String id) async {
    selectedPersonal.value =
        Personal.fromJson(await personalService.buscarPersonalPorId(id));
  }
}
