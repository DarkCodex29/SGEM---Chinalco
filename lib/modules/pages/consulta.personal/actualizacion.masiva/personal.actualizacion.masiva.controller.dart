import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/shared/modules/entrenamiento.actualizacion.masiva.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class ActualizacionMasivaController extends GetxController {
  RxBool isExpanded = true.obs;

  TextEditingController codigoMcpController = TextEditingController();
  TextEditingController numeroDocumentoController = TextEditingController();
  TextEditingController nombresController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();

  RxList<EntrenamientoActualizacionMasiva> entrenamientoResultados =
      <EntrenamientoActualizacionMasiva>[].obs;

  final rowsPerPage = 10.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalRecords = 0.obs;

  final isLoadingGuardia = false.obs;
  final entrenamientoService = EntrenamientoService();
  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();

  final _logger = Logger('ActualizacionMasivaController');

  @override
  void onInit() {
    dropdownController.selectValueKey('guardiaFiltro', 0);
    buscarActualizacionMasiva(
      pageNumber: currentPage.value,
      pageSize: rowsPerPage.value,
    );
    super.onInit();
  }

  Future<void> buscarActualizacionMasiva({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final codigoMcp =
        codigoMcpController.text.isEmpty ? null : codigoMcpController.text;
    final numeroDocumento = numeroDocumentoController.text.isEmpty
        ? null
        : numeroDocumentoController.text;
    final nombres =
        nombresController.text.isEmpty ? null : nombresController.text;
    final apellidos =
        apellidosController.text.isEmpty ? null : apellidosController.text;
    try {
      final response = await entrenamientoService.actualizacionMasivaPaginado(
        codigoMcp: codigoMcp,
        numeroDocumento: numeroDocumento,
        inGuardia:
            dropdownController.getSelectedValue('guardiaFiltro')?.key == 0
                ? null
                : dropdownController.getSelectedValue('guardiaFiltro')?.key,
        nombres: nombres,
        apellidos: apellidos,
        inEquipo: dropdownController.getSelectedValue('equipo')?.key,
        inModulo: dropdownController.getSelectedValue('modulo')?.key,
        pageSize: pageSize,
        pageNumber: pageNumber,
      );
      if (response.success && response.data != null) {
        try {
          final result = response.data!;
          _logger.info('Respuesta recibida correctamente $result');
          final items =
              result['Items'] as List<EntrenamientoActualizacionMasiva>;
          _logger.info('Items obtenidos: $items');
          entrenamientoResultados.assignAll(items);

          currentPage.value = result['PageNumber'] as int;
          totalPages.value = result['TotalPages'] as int;
          totalRecords.value = result['TotalRecords'] as int;
          rowsPerPage.value = result['PageSize'] as int;
          isExpanded.value = false;

          _logger
              .info('Resultados obtenidos: ${entrenamientoResultados.length}');
        } catch (e) {
          _logger.info('Error al procesar la respuesta: $e');
        }
      } else {
        _logger.info('Error en la búsqueda: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error en la actualizacion masiva búsqueda 2: $e');
    }
  }

  void clearFields() {
    codigoMcpController.clear();
    numeroDocumentoController.clear();
    nombresController.clear();
    apellidosController.clear();
    dropdownController
      ..resetAllSelections()
      ..selectValueKey('guardiaFiltro', 0);
  }
}
