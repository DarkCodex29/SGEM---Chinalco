import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.archivo.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/config/api/api.monitoring.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/config/api/api_fecha.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/estado.entrenamiento.dart';
import 'package:sgem/config/constants/origen.archivo.dart';
import 'package:sgem/config/constants/tipo.actividad.dart';
import 'package:sgem/shared/models/fecha.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/monitoring.detail.dart';
import 'package:sgem/shared/modules/monitoring.save.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/utils/functions/parse.date.time.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';

class CreateMonitoringController extends GetxController {
  final EntrenamientoService entrenamientoService = EntrenamientoService();
  final monitoringService = MonitoringService();
  final fechaService = FechaService();
  final PersonalService personalService = PersonalService();
  final codigoMCPController = TextEditingController();
  final codigoMCP2Controller = TextEditingController();
  final fullNameController = TextEditingController();
  final guardController = TextEditingController();
  final stateTrainingController = TextEditingController();
  final moduleController = TextEditingController();
  final commentController = TextEditingController();
  DateTime? fechaProximoMonitoreoController;
  DateTime? fechaRealMonitoreoController;
  final horasController = TextEditingController();
  final modelMonitoring = MonitoingSave(
    inTipoActividad: 0,
    inTipoPersona: 0,
    //inPersona: selectedPersonKey.value,
    inPersona: 0,
    inEquipo: 0,
    inEntrenador: 0,
    inCondicion: 0,
    inTotalHoras: 0,
    estadoEntrenamiento: OptionValue(),
  );

  RxBool isLoadingCodeMcp = false.obs;
  RxBool isSaving = false.obs;
  RxBool isLoandingSave = false.obs;
  RxBool isLoandingDetail = false.obs;
  Rxn<Uint8List?> personalPhoto = Rxn<Uint8List?>();

  var selectedEquipoKey = RxnInt();
  var selectedEntrenadorKey = RxnInt();
  var selectedModuloKey = RxnInt();
  var selectedGuardiaKey = RxnInt();
  var selectedEstadoEntrenamientoKey = RxnInt();
  var selectedCondicionKey = RxnInt();
  var selectedPersonKey = RxnInt();
  final ArchivoService archivoService = ArchivoService();
  var documentoAdjuntoNombre = ''.obs;
  var documentoAdjuntoBytes = Rxn<Uint8List>();
  var archivosAdjuntos = <Map<String, dynamic>>[].obs;
  var archivosAdjuntosOtros = <Map<String, dynamic>>[].obs;
  var personId = RxnInt();
  RxList<Fecha> fechas = <Fecha>[].obs;
  var inGuardiaSelected = RxnInt();

  clearModel() {
    modelMonitoring ==
        MonitoingSave(
          inTipoActividad: 0,
          inTipoPersona: 0,
          //inPersona: selectedPersonKey.value,
          inPersona: 0,
          inEquipo: 0,
          inEntrenador: 0,
          inCondicion: 0,
          inTotalHoras: 0,
          estadoEntrenamiento: OptionValue(),
        );
    selectedPersonKey.value = null;
    selectedEquipoKey.value = null;
    selectedEntrenadorKey.value = null;
    selectedCondicionKey.value = null;
    selectedEstadoEntrenamientoKey.value = null;
    fechaProximoMonitoreoController = null;
    fechaRealMonitoreoController = null;
    commentController.clear();
    horasController.text = "";
    modelMonitoring.key = null;
    codigoMCP2Controller.text = "";
    codigoMCPController.text = "";
    fullNameController.text = "";
    guardController.text = "";
    stateTrainingController.text = "";
    moduleController.text = "";
    selectedPersonKey.value = null;
    personalPhoto.value = null;
  }

  final Logger _logger = Logger('CreateMonitoringController');

  Future<bool> saveMonitoring(BuildContext context) async {
    _logger.info('Guardando monitoreo');
    bool state = false;
    try {
      if (selectedPersonKey.value == null) {
        mostrarErroresValidacion(context, ['No hay información de la persona']);
        return false;
      }
      if (selectedEquipoKey.value == null) {
        mostrarErroresValidacion(context, ['Por favor seleccione  el equipo']);
        return false;
      }
      if (selectedEntrenadorKey.value == null) {
        mostrarErroresValidacion(
          context,
          ['Por favor seleccione el  entrenador'],
        );
        return false;
      }
      if (selectedCondicionKey.value == null) {
        mostrarErroresValidacion(
          context,
          ['Por favor seleccione la condición'],
        );
        return false;
      }
      if (selectedEstadoEntrenamientoKey.value == null) {
        mostrarErroresValidacion(
          context,
          ['Por favor seleccione el estado del entrenamiento'],
        );
        return false;
      }

      _logger.info('Validando fechas');

      //Validar que la fecha aproximada de monitoreo este entre el rango de la lista de fechas
      if (fechaProximoMonitoreoController != null && fechas.length > 0) {
        bool esFechaValida =
            isFechaActualEnRango(fechaProximoMonitoreoController);

        // for (var rango in fechas) {
        //   if (fechaProximoMonitoreoController!.isAfter(rango.fechaInicio) &&
        //       fechaProximoMonitoreoController!.isBefore(rango.fechaFin)) {
        //     esFechaValida = true; // La fecha actual está en el rango

        //   }
        // }

        ///Vaslidar que la fecha de proximo monitoreo sea mayor que l afecha de fin (fecha real fin)

        if (!esFechaValida) {
          mostrarErroresValidacion(context, [
            'La fecha próxima de monitoreo no se encuentra disponible. Para consultar las fechas disponibles seleccione el icono (¡)',
          ]);
          return false;
        }
      }

      _logger.info('Validando horas');

      //TODO, Validar fecha real que sea mayo r la fecha de fin del entrenamiento
      final responseFechas = await entrenamientoService
          .listarEntrenamientoPorPersona(selectedPersonKey.value!);

      if (!responseFechas.success) {
        _logger.warning(
          'Error al obtener fechas de entrenamiento: ${responseFechas.message}',
        );
        if (context.mounted) {
          mostrarErroresValidacion(context, [
            responseFechas.message ??
                'Error al obtener fechas de entrenamiento',
          ]);
        }
        return false;
      }

      final trainingList = responseFechas.data!
          .map((json) => EntrenamientoModulo.fromJson(json))
          .toList();

      if (trainingList.isEmpty) return false;

      final entrenamientos = trainingList.where(
        (element) =>
            element.estadoEntrenamiento!.key! ==
                selectedEstadoEntrenamientoKey.value &&
            element.equipo!.key! == selectedEquipoKey.value,
      );

      if (entrenamientos.isEmpty) {
        _logger.warning(
          'Error al obtener entrenamiento: ${responseFechas.message}',
        );
        return false;
      }

      if (entrenamientos.first.fechaTermino == null ||
          (entrenamientos.first.fechaTermino != null &&
              fechaRealMonitoreoController!
                  .isAfter(entrenamientos.first.fechaTermino!))) {
        if (fechaProximoMonitoreoController != null &&
            fechaRealMonitoreoController!
                .isAfter(fechaProximoMonitoreoController!)) {
          mostrarErroresValidacion(context, [
            'La fecha próxima de monitoreo debe ser mayor a la fecha real de monitoreo',
          ]);
          return false;
        }

        modelMonitoring.inPersona = selectedPersonKey.value;
        modelMonitoring.inEquipo = selectedEquipoKey.value;
        modelMonitoring.inEntrenador = selectedEntrenadorKey.value;
        modelMonitoring.inCondicion = selectedCondicionKey.value;
        modelMonitoring.estadoEntrenamiento =
            OptionValue(key: selectedEstadoEntrenamientoKey.value, nombre: "");
        modelMonitoring.fechaProximoMonitoreo = fechaProximoMonitoreoController;
        modelMonitoring.fechaRealMonitoreo = fechaRealMonitoreoController;
        modelMonitoring.inTotalHoras = int.parse(horasController.text);
        modelMonitoring.comentarios = commentController.text;
        ResponseHandler<bool> response;

        //Validar tamaño de archivos adjuntos
        if (modelMonitoring.key == null || modelMonitoring.key == 0) {
          response =
              await monitoringService.registerMonitoring(modelMonitoring);
        } else {
          if (archivosAdjuntos.value.length == 0) {
            mostrarErroresValidacion(
              context,
              ['Debe adjuntar archivos de monitoreo de equipo pesado'],
            );
            return false;
          }

          response = await monitoringService.updateMonitoring(modelMonitoring);
        }
        if (response.success) {
          // ignore: use_build_context_synchronously
          _mostrarMensajeGuardado(context);
          state = true;
        } else {
          _logger.warning('Error al guardar monitoreo: ${response.message}');
          mostrarErroresValidacion(context, ['Error al guardar monitoreo']);
        }
      } else {
        mostrarErroresValidacion(context, [
          'La fecha real de monitoreo debe ser mayor a la fecha de fin del entrenamiento',
        ]);
      }
    } catch (e, stackTrace) {
      _logger.severe('Error al guardar monitoreo', e, stackTrace);
    } finally {
      isLoandingSave.value = false;
    }
    return state;
  }

  bool isFechaActualEnRango(DateTime? fechaActual) {
    // Ignorar la hora para solo comparar las fechas
    DateTime fechaActualSoloFecha =
        DateTime(fechaActual!.year, fechaActual.month, fechaActual.day);

    for (var objeto in fechas) {
      DateTime fechaInicioSoloFecha = DateTime(
        objeto.fechaInicio.year,
        objeto.fechaInicio.month,
        objeto.fechaInicio.day,
      );
      DateTime fechaFinSoloFecha = DateTime(
        objeto.fechaFin.year,
        objeto.fechaFin.month,
        objeto.fechaFin.day,
      );

      if (fechaActualSoloFecha.isAfter(fechaInicioSoloFecha) ||
          fechaActualSoloFecha.isAtSameMomentAs(fechaInicioSoloFecha)) {
        if (fechaActualSoloFecha.isBefore(fechaFinSoloFecha) ||
            fechaActualSoloFecha.isAtSameMomentAs(fechaFinSoloFecha)) {
          return true; // Salir del bucle si se encuentra un rango válido
        }
      }
    }

    return false; // Retorna false si no se encontró un rango válido
  }

  Future<void> adjuntarDocumentos(
    BuildContext context,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );

      if (result != null) {
        if (!validateFileSize(result.files.first)) {
          mostrarErroresValidacion(context, [
            'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.',
          ]);
          return;
        }

        for (var file in result.files) {
          if (file.bytes != null) {
            Uint8List fileBytes = file.bytes!;
            String fileName = file.name;

            archivosAdjuntos.add({
              'nombre': fileName,
              'bytes': fileBytes,
              'nuevo': true,
            });
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

  Future<void> uploadArchive() async {
    final archivosNuevos =
        archivosAdjuntos.where((archivo) => archivo['nuevo'] == true).toList();
    for (final archivo in archivosNuevos) {
      try {
        String datosBase64 = base64Encode(archivo['bytes']);
        String extension = archivo['nombre'].split('.').last;
        String mimeType = _determinarMimeType(extension);

        final response = await archivoService.registrarArchivo(
          key: 0,
          nombre: archivo['nombre'],
          extension: extension,
          mime: mimeType,
          datos: datosBase64,
          inTipoArchivo: OrigenArchivo.monitoreoEquipoPesado,
          inOrigen: TipoActividad.MONITOREO,
          inOrigenKey: modelMonitoring.key!,
        );

        if (response.success) {
          _logger.info('Archivo ${archivo['nombre']} registrado con éxito');
          archivo['nuevo'] = false;
        } else {
          _logger.info(
            'Error al registrar archivo ${archivo['nombre']}: ${response.message}',
          );
        }
      } catch (e) {
        _logger.info('Error al registrar archivo ${archivo['nombre']}: $e');
      }
    }
  }

  Future<void> adjuntarDocumentosOtros(
    BuildContext context,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );

      if (result != null) {
        if (!validateFileSize(result.files.first)) {
          mostrarErroresValidacion(context, [
            'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.',
          ]);
          return;
        }

        for (var file in result.files) {
          if (file.bytes != null) {
            Uint8List fileBytes = file.bytes!;
            String fileName = file.name;

            archivosAdjuntosOtros.add({
              'nombre': fileName,
              'bytes': fileBytes,
              'nuevo': true,
            });
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

  Future<void> uploadArchiveOtros() async {
    final archivosNuevos = archivosAdjuntosOtros
        .where((archivo) => archivo['nuevo'] == true)
        .toList();
    for (final archivo in archivosNuevos) {
      try {
        String datosBase64 = base64Encode(archivo['bytes']);
        String extension = archivo['nombre'].split('.').last;
        String mimeType = _determinarMimeType(extension);

        final response = await archivoService.registrarArchivo(
          key: 0,
          nombre: archivo['nombre'],
          extension: extension,
          mime: mimeType,
          datos: datosBase64,
          inTipoArchivo: OrigenArchivo.monitoreoOtros,
          inOrigen: TipoActividad.MONITOREO,
          inOrigenKey: modelMonitoring.key!,
        );

        if (response.success) {
          _logger.info('Archivo ${archivo['nombre']} registrado con éxito');
          archivo['nuevo'] = false;
        } else {
          _logger.info(
            'Error al registrar archivo ${archivo['nombre']}: ${response.message}',
          );
        }
      } catch (e) {
        _logger.info('Error al registrar archivo ${archivo['nombre']}: $e');
      }
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

//  inOrigen: TipoActividad.MONITOREO,
//           inOrigenKey: modelMonitoring.key!,

  Future<void> obtenerArchivosRegistrados(int idOrigen, int idOrigenKey) async {
    _logger.info('Obteniendo archivos registrados');
    _logger.info('idOrigen: $idOrigen, idOrigenKey: $idOrigenKey');
    try {
      final response = await archivoService.obtenerArchivosPorOrigen(
        idOrigen: TipoActividad.MONITOREO, // idOrigen,
        idOrigenKey: idOrigenKey,
        idTipoArchivo: OrigenArchivo.monitoreoEquipoPesado,
      );
      _logger.info('Response: ${response.data}');
      if (response.success && response.data != null) {
        archivosAdjuntos.clear();
        for (var archivo in response.data!) {
          List<int> datos = List<int>.from(archivo['Datos']);
          Uint8List archivoBytes = Uint8List.fromList(datos);

          archivosAdjuntos.add({
            'nombre': archivo['Nombre'],
            'bytes': archivoBytes,
            'key': archivo['Key'],
          });

          _logger.info('Archivo ${archivo['Nombre']} obtenido con éxito');
        }
      } else {
        _logger.info('Error al obtener archivos: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error al obtener archivos: $e');
    }
  }

  Future<void> obtenerArchivosRegistradosOtros(
    int idOrigen,
    int idOrigenKey,
  ) async {
    _logger.info('Obteniendo archivos registrados');
    _logger.info('idOrigen: $idOrigen, idOrigenKey: $idOrigenKey');
    try {
      final response = await archivoService.obtenerArchivosPorOrigen(
        idOrigen: TipoActividad.MONITOREO, // idOrigen,
        idOrigenKey: idOrigenKey,
        idTipoArchivo: OrigenArchivo.monitoreoOtros,
      );
      _logger.info('Response: ${response.data}');
      if (response.success && response.data != null) {
        archivosAdjuntosOtros.clear();
        for (var archivo in response.data!) {
          List<int> datos = List<int>.from(archivo['Datos']);
          Uint8List archivoBytes = Uint8List.fromList(datos);

          archivosAdjuntosOtros.add({
            'nombre': archivo['Nombre'],
            'bytes': archivoBytes,
            'key': archivo['Key'],
          });

          _logger.info('Archivo ${archivo['Nombre']} obtenido con éxito');
        }
      } else {
        _logger.info('Error al obtener archivos: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error al obtener archivos: $e');
    }
  }

  Future<void> eliminarArchivo(String nombreArchivo, int? key) async {
    if (key == null) {
      archivosAdjuntos.removeWhere(
        (archivo) =>
            archivo['key'] == key &&
            (archivo['nuevo'] == true || archivo['nuevo'] == null),
      );
      _logger.info(
        'Archivo $nombreArchivo eliminado, cantidad eliminados: ${archivosAdjuntos.length}',
      );
    } else {
      final response = await archivoService.eliminarArchivo(
        key: key,
        nombre: 'nombre',
        extension: 'extension',
        mime: 'mime',
        datos: null,
        inTipoArchivo: 0,
        inOrigen: 0,
        inOrigenKey: 0,
      );
      if (response.success) {
//modelMonitoring.key
        final respStatus =
            await monitoringService.updateMonitoringStatus(modelMonitoring);

        if (respStatus.success) {
          archivosAdjuntos.removeWhere(
            (archivo) =>
                archivo['key'] == key &&
                (archivo['nuevo'] == true || archivo['nuevo'] == null),
          );
          _logger.info(
            'Archivo $nombreArchivo eliminado, cantidad eliminados: ${archivosAdjuntos.length}',
          );
        }
      }
    }
  }

  Future<void> eliminarArchivoOtros(String nombreArchivo, int? key) async {
    if (key == null) {
      archivosAdjuntosOtros.removeWhere(
        (archivo) =>
            archivo['key'] == key &&
            (archivo['nuevo'] == true || archivo['nuevo'] == null),
      );
      _logger.info(
        'Archivo $nombreArchivo eliminado, cantidad eliminados: ${archivosAdjuntosOtros.length}',
      );
    } else {
      final response = await archivoService.eliminarArchivo(
        key: key,
        nombre: 'nombre',
        extension: 'extension',
        mime: 'mime',
        datos: null,
        inTipoArchivo: 0,
        inOrigen: 0,
        inOrigenKey: 0,
      );
      if (response.success) {
        final respStatus =
            await monitoringService.updateMonitoringStatus(modelMonitoring);

        if (respStatus.success) {
          archivosAdjuntosOtros.removeWhere(
            (archivo) =>
                archivo['key'] == key &&
                (archivo['nuevo'] == true || archivo['nuevo'] == null),
          );
          _logger.info(
            'Archivo $nombreArchivo eliminado, cantidad eliminados: ${archivosAdjuntosOtros.length}',
          );
        }
      }
    }
  }

  Future<void> descargarArchivo(
    BuildContext context,
    Map<String, dynamic> archivo,
  ) async {
    try {
      String nombreArchivo = archivo['nombre'];
      Uint8List archivoBytes = archivo['bytes'];
      String extension = nombreArchivo.split('.').last;
      if (nombreArchivo.endsWith('.$extension')) {
        nombreArchivo = nombreArchivo.substring(
          0,
          nombreArchivo.length - extension.length - 1,
        );
      }

      MimeType mimeType = _determinarMimeType2(extension);

      await FileSaver.instance.saveFile(
        name: nombreArchivo,
        bytes: archivoBytes,
        ext: extension,
        mimeType: mimeType,
      );

      context.snackbar(
        'Descarga exitosa',
        'El archivo $nombreArchivo.$extension se descargó correctamente',
      );
    } catch (e) {
      _logger.info('Error al descargar el archivo $e');
      context.snackbar(
        'Error',
        'No se pudo descargar el archivo: $e',
      );
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

  Future<bool> deleteMonitoring(BuildContext context) async {
    bool state = false;
    try {
      final response =
          await monitoringService.deleteMonitoring(modelMonitoring);
      if (response.success) {
        _mostrarMensajeGuardado(
          // ignore: use_build_context_synchronously
          context,
          title: "Monitoreo Eliminado",
        );
        state = true;
        clearModel();
      } else {
        mostrarErroresValidacion(context, ['Error al Eliminar monitoreo']);
      }
    } catch (e) {
      _logger.info('Error: $e');
    } finally {
      isLoandingSave.value = false;
    }
    return state;
  }

  Future<void> searchPersonByCodeMcp(
    BuildContext context,
  ) async {
    if (codigoMCPController.text.isEmpty) {
      mostrarErroresValidacion(context, ['Ingrese un Código MCP válido.']);
      resetInfoPerson();
      return;
    }
    try {
      isLoadingCodeMcp.value = true;
      final responseListar = await personalService.listarPersonalEntrenamiento(
        codigoMcp: codigoMCPController.text,
      );
      if ((responseListar.data == null || responseListar.data!.isEmpty)) {
        mostrarErroresValidacion(
          context,
          ['El personal no se encuentra registrado en el sistema.'],
        );
        resetInfoPerson();
        clearModel();
      }
      await setInfoPerson(context, responseListar.data!.last);
      personId.value = responseListar.data!.last.id;

      await loadPersonalPhoto(responseListar.data!.first.inPersonalOrigen!);
    } catch (e) {
      _logger.info('Error inesperado al buscar el personal: $e');
    } finally {
      isLoadingCodeMcp.value = false;
    }
  }

  Future<void> fetchTrainings(BuildContext context, int personId) async {
    try {
      _logger.info("Entrenamiento Controller: $personId");
      final response =
          await entrenamientoService.listarEntrenamientoPorPersona(personId);
      if (response.success) {
        final trainingList = response.data!
            .map((json) => EntrenamientoModulo.fromJson(json))
            .toList();
        if (trainingList
                .where(
                  (element) =>
                      element.estadoEntrenamiento!.key! !=
                      EstadoEntrenamiento.paralizado,
                )
                .length ==
            0) {
          mostrarErroresValidacion(
            context,
            ['No se encontraron entrenamientos para el código ingresado.'],
          );
          resetInfoPerson();
          clearModel();
        } else {
          if (trainingList
                  .where(
                    (element) =>
                        element.estadoEntrenamiento!.key! ==
                        EstadoEntrenamiento.autorizado,
                  )
                  .length >
              0) {
            await _fetchAndCombineUltimoModulo(
              trainingList
                  .where(
                    (element) =>
                        element.estadoEntrenamiento!.key! ==
                        EstadoEntrenamiento.autorizado,
                  )
                  .first,
            );
          } else {
            for (var training in trainingList) {
              await _fetchAndCombineUltimoModulo(training);
            }
          }
        }
      } else {
        context.snackbar('Error', 'No se pudieron cargar los entrenamientos');
      }
    } catch (e) {
      context.snackbar(
        'Error',
        'Ocurrió un problema al cargar los entrenamientos',
      );
    }
  }

  Future<void> _fetchAndCombineUltimoModulo(
    EntrenamientoModulo training,
  ) async {
    try {
      final response = await entrenamientoService
          .obtenerUltimoModuloPorEntrenamiento(training.key!);
      if (response.success && response.data != null) {
        EntrenamientoModulo ultimoModulo = response.data!;
        training.actualizarConUltimoModulo(ultimoModulo);

        stateTrainingController.text =
            training.estadoEntrenamiento!.key == EstadoEntrenamiento.paralizado
                ? ''
                : (training.estadoEntrenamiento!.nombre ?? "");
        moduleController.text =
            training.estadoEntrenamiento!.key == EstadoEntrenamiento.autorizado
                ? 'Finalizado'
                : training.modulo!.nombre ?? "";
      } else {
        _logger.info('Error al obtener el último módulo: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error al obtener el último módulo: $e');
    }
  }

  Future<void> loadPersonalPhoto(int idOrigen) async {
    try {
      final photoResponse =
          await personalService.obtenerFotoPorCodigoOrigen(idOrigen);

      if (photoResponse.success && photoResponse.data != null) {
        personalPhoto.value = photoResponse.data;
      } else {
        _logger.info('Error al cargar la foto: ${photoResponse.message}');
      }
    } catch (e) {
      _logger.info('Error al cargar la foto del personal: $e');
    }
  }

  Future<void> searchMonitoringDetailById(BuildContext context, int key) async {
    try {
      isLoandingDetail.value = true;
      final result = await monitoringService.searchMonitoringDetailById(key);
      final monitoring = MonitoringDetail.fromJson(result);
      selectedPersonKey.value = monitoring.inPersona;
      selectedEquipoKey.value = monitoring.equipo?.key;
      selectedEntrenadorKey.value = monitoring.entrenador?.key;
      selectedCondicionKey.value = monitoring.condicion?.key;
      selectedEstadoEntrenamientoKey.value =
          monitoring.estadoEntrenamiento?.key;
      fechaProximoMonitoreoController = monitoring.fechaProximoMonitoreo == null
          ? null
          : FnDateTime.fromDotNetDate(monitoring.fechaProximoMonitoreo ?? "");
      fechaRealMonitoreoController =
          FnDateTime.fromDotNetDate(monitoring.fechaRealMonitoreo ?? "");
      horasController.text = monitoring.inTotalHoras.toString();
      modelMonitoring.key = monitoring.key;
      commentController.text = monitoring.comentarios ?? "";
      final personalInfo = await personalService
          .buscarPersonalPorId(monitoring.inPersona!.toString());
      final person = Personal.fromJson(personalInfo);
      codigoMCPController.text = person.codigoMcp!;
      await searchPersonByCodeMcp(
        context,
      );
      isLoandingDetail.value = false;
      await obtenerArchivosRegistrados(1, monitoring.key!);
      await obtenerArchivosRegistradosOtros(1, monitoring.key!);
      codigoMCP2Controller.text = person.codigoMcp!;

      // monitoring.
    } catch (e) {
      _logger.info('error al obtener la información del monitoreo');
    }
  }

  setInfoPerson(BuildContext context, Personal person) async {
    codigoMCP2Controller.text = person.codigoMcp!;
    fullNameController.text = "${person.nombreCompleto}";
    // fullNameController.text = "${person.apellidoPaterno} ${person.apellidoMaterno} ${person.segundoNombre}";
    guardController.text = person.guardia!.nombre!;
    stateTrainingController.text = "";
    moduleController.text = "";
    selectedPersonKey.value = person.key;
    await fetchTrainings(context, person.key!);
    await obtenerFechasPorGuardia(person.guardia!.key ?? 0);
  }

  Future<void> obtenerFechasPorGuardia(int inGuardia) async {
    try {
      final response = await fechaService.getFechasPaginado(
        pageSize: 1000,
        pageNumber: 1,
        inGuardia: inGuardia,
      );

      if (response.success && response.data != null) {
        var result = response.data as Map<String, dynamic>;

        var items = result['Items'] as List<Fecha>;

        fechas.assignAll(items);
      }
    } catch (e) {}
  }

  resetInfoPerson() {
    codigoMCP2Controller.text = "";
    fullNameController.text = "";
    guardController.text = "";
    stateTrainingController.text = "";
    moduleController.text = "";
  }

  void _mostrarMensajeGuardado(
    BuildContext context, {
    String title = "Los datos se guardaron \nsatisfactoriamente",
  }) {
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
    _logger.warning('Errores de validación: $errores');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MensajeValidacionWidget(errores: errores);
      },
    );
  }
}
