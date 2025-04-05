import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/Repository/DTO/MaestroDetaille.dart';
import 'package:sgem/config/Repository/MainRespository.dart';
import 'package:sgem/config/api/api.archivo.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/config/constants/tipo.archivo.entrenamiento.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/shared/models/maestro_detalle.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class EntrenamientoNuevoController extends GetxController {
  TextEditingController fechaInicioController = TextEditingController();
  TextEditingController fechaTerminoController = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaTermino;
  TextEditingController observacionesEntrenamiento = TextEditingController();

  EntrenamientoPersonalController controllerPersonal =
      Get.put(EntrenamientoPersonalController());

  RxList<MaestroDetalle> equipoDetalle = <MaestroDetalle>[].obs;
  RxList<MaestroDetalle> condicionDetalle = <MaestroDetalle>[].obs;
  RxList<MaestroDetalle> estadoDetalle = <MaestroDetalle>[].obs;

  final _logger = Logger('EntrenamientoNuevoController');

  final DropdownController equipoController = DropdownController();

  Rxn<MaestroDetalle?> condicionSelected = Rxn<MaestroDetalle?>();
  late final condicionSelectedBinding = Binding(
    get: () {
      return condicionSelected.value;
    },
    set: (DropdownElement? newValue) {
      condicionSelected.value = newValue! as MaestroDetalle;
      return;
    },
  );

  DropdownController trainStatus = DropdownController();
  final trainingService = EntrenamientoService();

  final archivoService = ArchivoService();

  RxBool isLoading = false.obs;

  //var documentoAdjuntoNombre = ''.obs;
  //var documentoAdjuntoBytes = Rxn<Uint8List>();
  RxList<Map<String, dynamic>> archivosAdjuntos = <Map<String, dynamic>>[].obs;
  RxBool isLoadingFiles = false.obs;

  MainRepository repository = MainRepository();

  @override
  void onInit() {
    super.onInit();
    //add listener para sincronizar el texto con fechaInicio
    fechaInicioController.addListener(() {
      final text = fechaInicioController.text;
      try {
        fechaInicio =
            text.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(text) : null;
      } catch (_) {
        fechaInicio = null;
      }
    });
    getEquiposAndConditions();
  }

  Future<void> getEquiposAndConditions() async {
    isLoading.value = true;
    try {
      final equiposFuture = repository
          .listarMaestroDetallePorMaestro(MaestroDetalleTypes.equipo.rawValue);
      final condicionesFuture = repository.listarMaestroDetallePorMaestro(
        MaestroDetalleTypes.condicionEntrenamiento.rawValue,
      );
      final estadosEntrenamientoFuture =
          repository.listarMaestroDetallePorMaestro(
        MaestroDetalleTypes.estadoEntrenamiento.rawValue,
      );

      final results = await Future.wait(
        [equiposFuture, condicionesFuture, estadosEntrenamientoFuture],
      );
      final equipos = results[0];
      final condiciones = results[1];
      final estados = results[2];

      if (equipos != null) equipoDetalle.assignAll(equipos);
      if (condiciones != null) condicionDetalle.assignAll(condiciones);
      if (estados != null) estadoDetalle.assignAll(estados);

      _logger.info('Datos de equipos y condiciones cargados correctamente');
    } catch (e) {
      _logger.info('Error al cargar equipos o condiciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void removerArchivo(String nombreArchivo) {
    archivosAdjuntos.removeWhere(
      (archivo) =>
          archivo['nombre'] == nombreArchivo && archivo['nuevo'] == true,
    );
    //documentoAdjuntoNombre.value = '';
  }

  Future<void> eliminarArchivo(
      BuildContext context, Map<String, dynamic> archivo) async {
    try {
      final response = await archivoService.eliminarArchivo(
        key: archivo['key'] as int,
        nombre: archivo['nombre'] as String,
        extension: archivo['extension'] as String,
        mime: archivo['mime'] as String,
        datos: archivo['datos'] as String,
        inTipoArchivo: 1,
        inOrigen: 2,
        inOrigenKey: archivo['inOrigenKey'] as int,
      );

      if (response.success) {
        await obtenerArchivosRegistrados(
            context, 2, archivo['inOrigenKey'] as int);
      } else {
        context.snackbar(
          'Error',
          'No se pudo eliminar el archivo: ${response.message}',
        );
      }
    } catch (e) {
      _logger.info('Error al eliminar el archivo: $e');
      context.snackbar(
        'Error',
        'No se pudo eliminar el archivo: $e',
      );
    }
  }

  bool validateFileSize(PlatformFile file) {
    const int maxFileSize = 4 * 1024 * 1024; // 4 MB en bytes

    if (file.size > maxFileSize) {
      print("El archivo supera los 4 MB.");
      return false;
    } else {
      print("El archivo es válido.");
      return true;
    }
  }

  Future<void> adjuntarDocumentos(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );

      if (result != null) {
        if (!validateFileSize(result.files.first)) {
          mostrarErroresValidacion(context, [
            'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.'
          ]);

          return;
        }
        for (final file in result.files) {
          if (file.bytes != null) {
            final fileBytes = file.bytes!;
            final fileName = file.name;
            archivosAdjuntos.add({
              'nombre': fileName,
              'bytes': fileBytes,
              'nuevo': true,
            });
            //documentoAdjuntoNombre.value = fileName;
            _logger.info('Documento adjuntado correctamente: $fileName');
          }
        }
      } else {
        _logger.info('No se seleccionaron archivos');
      }
    } catch (e) {
      _logger.info('Error al adjuntar documentos: $e');
    }
  }

  Future<void> registrarArchivos(int inOrigenKey) async {
    try {
      final archivosNuevos = archivosAdjuntos
          .where((archivo) => archivo['nuevo'] == true)
          .toList();
      for (final archivo in archivosNuevos) {
        try {
          final datosBase64 = base64Encode(archivo['bytes'] as List<int>);
          final extension = (archivo['nombre'] as String).split('.').last;
          final mimeType = _determinarMimeType(extension);
          final response = await archivoService.registrarArchivo(
            key: 0,
            nombre: archivo['nombre'] as String,
            extension: extension,
            mime: mimeType,
            datos: datosBase64,
            inTipoArchivo: TipoArchivoEntrenamiento.OTROS,
            inOrigen: 2, // TABLA Entrenamiento
            inOrigenKey: inOrigenKey,
          );
          if (response.success) {
            archivo['nuevo'] = false;
          }
        } catch (e) {
          _logger.info('Error al registrar archivo ${archivo['nombre']}: $e');
        }
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
    }
  }

  Future<void> descargarArchivo(
      BuildContext context, Map<String, dynamic> archivo) async {
    try {
      var nombreArchivo = archivo['nombre'] as String;
      final extension = archivo['extension'] as String;
      final datosBase64 = archivo['datos'] as String;
      final archivoBytes = base64Decode(datosBase64);

      if (nombreArchivo.endsWith('.$extension')) {
        nombreArchivo = nombreArchivo.substring(
          0,
          nombreArchivo.length - extension.length - 1,
        );
      }
      final mimeType = _determinarMimeType2(extension);
      await FileSaver.instance.saveFile(
        name: nombreArchivo,
        bytes: archivoBytes,
        ext: extension,
        mimeType: mimeType,
      );
    } catch (e) {
      _logger.info('Error al descargar el archivo $e');
      context.snackbar(
        'Error',
        'No se pudo descargar el archivo: $e',
      );
    }
  }

  Future<void> obtenerArchivosRegistrados(
      BuildContext context, int idOrigen, int inOrigenKey) async {
    try {
      isLoadingFiles.value = true;

      final response = await archivoService.getFilesByOrigin(
        origin: idOrigen, // 2: TABLA Entrenamiento
        originKey: inOrigenKey,
        fileType: TipoArchivoEntrenamiento.OTROS,
      );

      _logger.info('Response de archivos: ${response}');

      if (!response.success || response.data == null) {
        _logger.info('Error al obtener archivos: ${response.message}');
        MensajeValidacionWidget(
          errores: [
            response.message ?? 'Error al obtener archivos',
          ],
        ).show(context);
        return;
      }

      archivosAdjuntos.clear();
      for (final archivo in response.data!) {
        // final datos = List<int>.from(
        //   (archivo as Map<String, dynamic>)['Datos'] as List<dynamic>,
        // );
        final archivoBytes = Uint8List.fromList(archivo.datos);

        archivosAdjuntos.add({
          'key': archivo.key,
          'nombre': archivo.nombre,
          'extension': archivo.extension,
          'mime': archivo.mime,
          'datos': base64Encode(archivoBytes),
          'inOrigenKey': inOrigenKey,
          'nuevo': false,
        });
        _logger.info('Archivo ${archivo.nombre} obtenido con éxito');
      }
    } catch (e) {
      _logger.info('Error al obtener archivos: $e');
    } finally {
      isLoadingFiles.value = false;
    }
  }

  String _determinarMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  MimeType _determinarMimeType2(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return MimeType.pdf;
      case 'doc':
      case 'docx':
        return MimeType.microsoftWord;
      case 'xlsx':
        return MimeType.microsoftExcel;
      default:
        return MimeType.other;
    }
  }

  Future<bool> registertraining(
      BuildContext context, EntrenamientoModulo register) async {
    _logger.info('Registrando entrenamiento');
    try {
      isLoading.value = true;
      final response = await trainingService.registerTraining(register);

      if (response.success) {
        unawaited(
            controllerPersonal.fetchTrainings(context, register.inPersona!));
        return true;
      } else {
        MensajeValidacionWidget.single(
          response.message ?? 'Error al registrar entrenamiento',
        ).show(context);
        return false;
      }
    } catch (error, stackTrace) {
      _logger.severe(
        'Error al registrar entrenamiento $register',
        error,
        stackTrace,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearFieldFechas() {
    fechaInicioController.clear();
    fechaTerminoController.clear();
  }

  void clearFields() {
    observacionesEntrenamiento.clear();
    equipoController.clear();
    // equipoSelected.value = null;
    condicionSelected.value = null;
    trainStatus.value = null;
    fechaInicioController.clear();
    fechaTerminoController.clear();
    archivosAdjuntos.clear();
  }

  void completeFields(BuildContext context, EntrenamientoModulo entrenamiento) {
    if (equipoDetalle.isEmpty) {
      context.errorSnackbar('No se han cargado los datos de los equipos');
      return;
    }
    equipoController.value = entrenamiento.inEquipo;
    // equipoSelected.value =
    //     equipoDetalle.firstWhereOrNull((e) => e.key == entrenamiento.inEquipo);
    condicionSelected.value = condicionDetalle
        .firstWhereOrNull((e) => e.key == entrenamiento.inCondicion);
    trainStatus.value = entrenamiento.estadoEntrenamiento?.key;
    // estadoDetalle.firstWhereOrNull(
    //   (e) => e.key == entrenamiento.estadoEntrenamiento?.key,
    // );
    // estadoEntrenamientoSelected.value =
    //     estadoDetalle.firstWhereOrNull((e) => e.key == entrenamiento.inEstado);

    fechaInicio = entrenamiento.fechaInicio;
    fechaInicioController.text = entrenamiento.fechaInicio != null
        ? DateFormat('dd/MM/yyyy').format(entrenamiento.fechaInicio!)
        : '';

    //fechaInicioController.text = entrenamiento.fechaInicio?.format ?? '';
    fechaTerminoController.text = entrenamiento.fechaTermino?.format ?? '';

    observacionesEntrenamiento.text = entrenamiento.observaciones ?? '';
    obtenerArchivosRegistrados(context, 2, entrenamiento.key!);
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
