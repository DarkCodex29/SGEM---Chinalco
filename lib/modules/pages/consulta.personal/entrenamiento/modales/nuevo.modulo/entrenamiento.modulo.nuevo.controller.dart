import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.archivo.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/config/api/api.modulo.maestro.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/config/constants/origen.archivo.dart';
import 'package:sgem/config/constants/tipo.archivo.modulo.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/modulo.maestro.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/utils/functions/date_comparator.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class EntrenamientoModuloNuevoController extends GetxController {
  TextEditingController fechaInicioController = TextEditingController();
  TextEditingController fechaTerminoController = TextEditingController();
  TextEditingController notaTeoricaController =
      TextEditingController(text: '0');
  TextEditingController notaPracticaController =
      TextEditingController(text: '0');
  TextEditingController fechaExamenController = TextEditingController();

  // Cambiado a Rx
  Rx<TextEditingController> totalHorasModuloController =
      TextEditingController(text: '0').obs;

  TextEditingController horasAcumuladasController =
      TextEditingController(text: '0');
  TextEditingController horasMinestarController =
      TextEditingController(text: '0');

  DateTime? fechaInicio;
  DateTime? fechaTermino;
  DateTime? fechaExamen;

  ArchivoService archivoService = ArchivoService();
  ModuloMaestroService moduloMaestroService = ModuloMaestroService();
  PersonalService personalService = PersonalService();
  EntrenamientoService entrenamientoService = EntrenamientoService();

  List<String> errores = [];

  TextEditingController aaControlHorasController = TextEditingController();
  TextEditingController aaExamenTeoricoController = TextEditingController();
  TextEditingController aaExamenPracticoController = TextEditingController();
  TextEditingController aaOtrosController = TextEditingController();

  final aaControlHorasSeleccionado = false.obs;
  final aaExamenTeoricoSeleccionado = false.obs;
  final aaExamenPracticoSeleccionado = false.obs;
  final aaOtrosSeleccionado = false.obs;

  Uint8List? aaControlHorasFileBytes;
  Uint8List? aaExamenTeoricoFileBytes;
  Uint8List? aaExamenPracticoFileBytes;
  Uint8List? aaOtrosFileBytes;

  final aaControlHorasExiste = false.obs;
  final aaExamenTeoricoExiste = false.obs;
  final aaExamenPracticoExiste = false.obs;
  final aaOtrosExiste = false.obs;

  final aaControlHorasId = 0.obs;
  final aaExamenTeoricoId = 0.obs;
  final aaExamenPracticoId = 0.obs;
  final aaOtrosId = 0.obs;

  final isSaving = false.obs;

  EntrenamientoModulo? entrenamiento;
  ModuloMaestro? moduloMaestro;

  int entrenamientoId = 0;
  int entrenamientoModuloId = 0;
  int? siguienteModulo;
  bool isEdit = false;
  bool isView = false;
  final tituloModal = ''.obs;
  final inModulo = 1.obs;
  final isLoadingModulo = false.obs;

  EntrenamientoModulo? entrenamientoModulo;

  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();

  static final Logger _logger = Logger('EntrenamientoModuloNuevoController');

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

  Future<void> descargarArchivo(
    BuildContext context,
    Uint8List archivoBytes, {
    String nombreArchivo = 'archivo',
  }) async {
    try {
      final extension = nombreArchivo.split('.').last;
      final mimeType = _determinarMimeType2(extension);
      await FileSaver.instance.saveFile(
        name: nombreArchivo,
        bytes: archivoBytes,
        ext: extension,
        mimeType: mimeType,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error al descargar el archivo', e, stackTrace);
      if (context.mounted) {
        context.snackbar(
          'Error',
          'No se pudo descargar el archivo',
        );
      }
    }
  }

  Future<void> obtenerDatosModuloMaestro(context, int moduloNumero) async {
    _logger.info('Fetching Modulo: $moduloNumero');
    final response =
        await moduloMaestroService.obtenerModuloMaestroPorId(moduloNumero);

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [
          response.message ?? 'Hubo un error al obtener el módulo maestro',
        ],
      ).show(context);
    }

    moduloMaestro = response.data;
    _logger.info('horas: ${moduloMaestro!.inHoras}');
    totalHorasModuloController.value.text = moduloMaestro!.inHoras.toString();
  }

  Future<bool> registrarModulo(BuildContext context) async {
    try {
      _logger.info('Registrando módulo...');
      final modulo = EntrenamientoModulo(
        key: isEdit ? entrenamientoModuloId : 0,
        inTipoActividad: entrenamiento!.inTipoActividad,
        inActividadEntrenamiento: entrenamiento!.key,
        inPersona: entrenamiento!.inPersona,
        inEntrenador: dropdownController.getSelectedValue('entrenador')?.key,
        entrenador: entrenamiento!.entrenador,
        fechaInicio: fechaInicio,
        fechaTermino: fechaTermino,
        fechaExamen: fechaExamen,
        inNotaTeorica: int.tryParse(notaTeoricaController.text),
        inNotaPractica: int.tryParse(notaPracticaController.text),
        inTotalHoras: int.tryParse(totalHorasModuloController.value.text),
        inHorasAcumuladas: int.tryParse(horasAcumuladasController.text),
        inHorasMinestar: int.tryParse(horasMinestarController.text),
        inModulo: inModulo.value,
        modulo: OptionValue(key: inModulo.value, nombre: ''),
        eliminado: 'N',
        motivoEliminado: '',
        tipoPersona: entrenamiento!.tipoPersona,
        inCategoria: entrenamiento!.inCategoria,
        inEquipo: entrenamiento!.inEquipo,
        equipo: entrenamiento!.equipo,
        inEmpresaCapacitadora: entrenamiento!.inEmpresaCapacitadora,
        inCondicion: entrenamiento!.inCondicion,
        condicion: entrenamiento!.condicion,
        inEstado: isEdit == true
            ? dropdownController.getSelectedValue('estadoModulo')!.key
            : 0,
        estadoEntrenamiento: const OptionValue(key: 0, nombre: 'Pendiente'),
        comentarios: '',
        inCapacitacion: 0,
        observaciones: entrenamiento!.observaciones,
      );

      _logger.info('Validando módulo...');
      if (!validar(context, modulo)) return false;
      _logger.info('Módulo validado');

      _logger.info(jsonEncode(modulo.toJson()));

      final response = isEdit
          ? await moduloMaestroService.updateModulo(modulo)
          : await moduloMaestroService.registrateModulo(modulo);
      //if (response.success && response.data != null) {
      if (response.success) {
        final controller = Get.put(EntrenamientoPersonalController());
        await controller.fetchModulosPorEntrenamiento(
            context, modulo.inActividadEntrenamiento!);
        await controller.fetchTrainings(context, modulo.inPersona!);

        return true;
      } else {
        MensajeValidacionWidget(
          errores: [
            response.message ??
                'Hubo un error al ${isEdit ? "actualizar" : "registrar"} '
                    'el módulo',
          ],
        ).show(context);
        _logger.info(
          'Error al ${isEdit ? "actualizar" : "registrar"} módulo:'
          ' ${response.message}',
        );

        return false;
      }
    } catch (e, stacktrace) {
      _logger.severe('Error al registrar módulo', e, stacktrace);
      return false;
    }
  }

  bool validar(BuildContext context, EntrenamientoModulo modulo) {
    final errors = <String>[];

    if (moduloMaestro == null) {
      const MensajeValidacionWidget(
        errores: ['No se pudo obtener el módulo maestro.'],
      ).show(context);
      return false;
    }

    if (dropdownController.getSelectedValue('entrenador') == null) {
      errors.add('Debe seleccionar un entrenador responsable.');
    }

    final fechaInicio = modulo.fechaInicio;
    final fechaTermino = modulo.fechaTermino;
    final fechaExamen = modulo.fechaExamen;

    if (fechaExamen == null) {
      errors.add('Debe seleccionar una fecha de examen.');
    }

    if (modulo.inModulo == 1) {
      final trainingStartDate = entrenamiento!.fechaInicio!;
      final trainingEndDate = entrenamiento!.fechaTermino;

      if (fechaInicio != null && fechaInicio.isBefore(trainingStartDate)) {
        errors.add(
          'La fecha de inicio del Módulo I no puede ser anterior a la '
          'fecha de inicio del entrenamiento.',
        );
      }

      if (fechaInicio != null &&
          trainingEndDate != null &&
          dateIsAfter(fechaInicio, trainingEndDate)) {
        errors.add(
          'La fecha de inicio del Módulo I no puede ser posterior a la '
          'fecha de término del entrenamiento.',
        );
      }
    }

    if (fechaInicio == null) {
      errors.add('Debe seleccionar una fecha de inicio.');
    } else {
      if (fechaExamen != null && dateIsAfter(fechaInicio, fechaExamen)) {
        errors.add(
          'La fecha de examen debe ser mayor o igual a la '
          'fecha de inicio de módulo',
        );
      }
    }

    if (fechaTermino != null && fechaInicio != null) {
      if (dateIsBefore(fechaTermino, fechaInicio)) {
        errors.add(
          'La fecha de término no puede ser anterior a la fecha de inicio.',
        );
      }
    }

    final isCompleting = modulo.inEstado == 28;

    _logger.info('isCompleting: $isCompleting');

    if (isCompleting) {
      final notaTeorica = modulo.inNotaTeorica ?? 0;
      final notaPractica = modulo.inNotaPractica ?? 0;
      final horasAcumuladas = modulo.inHorasAcumuladas ?? 0;

      final minNota = moduloMaestro!.inNotaMinima!;
      final maxNota = moduloMaestro!.inNotaMaxima!;
      final minHoras = moduloMaestro!.inHoras!;
      _logger.info('minNota: $minNota, maxNota: $maxNota, minHoras: $minHoras');

      if (notaTeorica < minNota || notaTeorica > maxNota) {
        errors.add(
          'La nota teórica debe ser un número entre $minNota y $maxNota.',
        );
      }

      if (notaPractica < minNota || notaPractica > maxNota) {
        errors.add(
          'La nota práctica debe ser un número entre $minNota y $maxNota.',
        );
      }

      if (modulo.fechaExamen == null) {
        errors.add('Debe seleccionar una fecha de examen.');
      }

      if (minHoras > horasAcumuladas) {
        errors.add(
          'Las horas acumuladas debe ser mayor o igual a : $minHoras',
        );
      }
    }

    if (errors.isNotEmpty) {
      MensajeValidacionWidget(errores: errors).show(context);
      return false;
    }

    return true;
  }

  Future<void> nuevoModulo(BuildContext context, int inEntrenamiento) async {
    tituloModal.value = 'Nuevo Modulo';

    final response =
        await entrenamientoService.obtenerEntrenamientoPorId(inEntrenamiento);

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [
          response.message ?? 'Hubo un error al obtener el entrenamiento',
        ],
      ).show(context);
    }

    entrenamiento = response.data;

    final responseModulo = await entrenamientoService
        .obtenerUltimoModuloPorEntrenamiento(inEntrenamiento);

    if (!responseModulo.success) {
      return MensajeValidacionWidget(
        errores: [
          responseModulo.message ?? 'Hubo un error al obtener el módulo',
        ],
      ).show(context);
    }

    dropdownController.resetSelection('entrenador');

    final lastModulo = responseModulo.data!.inModulo;
    _logger.info('Ultimo modulo: $lastModulo');

    final int? nextModulo;
    if (entrenamiento!.isCondicionExperiencia) {
      nextModulo = lastModulo == null ? 1 : 4;
    } else if (entrenamiento!.isCondicionEntrenamiento) {
      nextModulo = (lastModulo ?? 0) + 1;
    } else {
      nextModulo = null;
    }

    if (nextModulo == null) {
      return const MensajeValidacionWidget(
        errores: ['No se puede agregar un nuevo módulo'],
      ).show(context);
    }

    final letter = switch (nextModulo) {
      1 => 'I',
      2 => 'II',
      3 => 'III',
      4 => 'IV',
      _ => '?',
    };

    await obtenerDatosModuloMaestro(context, nextModulo);
    inModulo.value = nextModulo;
    if (nextModulo == 1) {
      final startDate = entrenamiento!.fechaInicio;

      fechaInicio = startDate;
      fechaInicioController.text = startDate?.format ?? '';
    } else {
      final startDate =
          responseModulo.data!.fechaTermino?.add(const Duration(days: 1));

      fechaInicio = startDate;
      fechaInicioController.text = startDate?.format ?? '';
    }
    tituloModal.value = 'Nuevo Modulo - Modulo $letter';
  }

  Future<void> obtenerModuloPorId(
    BuildContext context,
    int inEntrenamiento,
    int inEntrenamientoModulo,
  ) async {
    final responseEntrenamiento =
        await entrenamientoService.obtenerEntrenamientoPorId(inEntrenamiento);

    if (responseEntrenamiento.success) {
      _logger.info('Obteniendo entrenamiento por id: $inEntrenamiento');
      entrenamiento = responseEntrenamiento.data;
      entrenamientoId = inEntrenamiento;
      entrenamientoModuloId = inEntrenamientoModulo;
      _logger.info('Entrenamiento: ${entrenamiento!.condicion!.nombre!}');
    }

    try {
      _logger.info('Obteniendo modulo por id: $inEntrenamientoModulo');
      final response =
          await moduloMaestroService.obtenerModuloPorId(inEntrenamientoModulo);

      _logger.info('Obteniendo modulo por id: ${response.success}');
      if (response.success) {
        _logger.info('Modulo obtenido: ${response.data}');
        entrenamientoModulo = response.data;
        await obtenerDatosModuloMaestro(
            context, entrenamientoModulo!.inModulo!);
        await llenarDatos(
          context,
        );
      } else {
        context.snackbar('Error', 'No se pudieron cargar el módulo');
      }
    } catch (e) {
      context.snackbar('Error', 'Ocurrió un problema al cargar el módulo');
    }
  }

  String formatoFechaPantalla(DateTime? fecha) {
    return fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : '';
  }

  Future<void> llenarDatos(
    BuildContext context,
  ) async {
    fechaInicio = entrenamientoModulo!.fechaInicio;
    fechaInicioController.text = formatoFechaPantalla(fechaInicio);
    fechaTermino = entrenamientoModulo!.fechaTermino;
    fechaTerminoController.text = formatoFechaPantalla(fechaTermino);
    notaTeoricaController.text = entrenamientoModulo!.inNotaTeorica.toString();
    notaPracticaController.text =
        entrenamientoModulo!.inNotaPractica.toString();
    fechaExamen = entrenamientoModulo!.fechaExamen;
    fechaExamenController.text = formatoFechaPantalla(fechaExamen);
    totalHorasModuloController.value.text =
        entrenamientoModulo!.inTotalHoras.toString();
    horasAcumuladasController.text =
        entrenamientoModulo!.inHorasAcumuladas.toString();
    horasMinestarController.text =
        entrenamientoModulo!.inHorasMinestar.toString();
    tituloModal.value = isView
        ? 'Ver Módulo - ${entrenamientoModulo!.modulo!.nombre!}'
        : 'Editar Módulo - ${entrenamientoModulo!.modulo!.nombre!}';

    dropdownController
      ..selectValueKey(
        'entrenador',
        entrenamientoModulo!.inEntrenador,
      )
      ..selectValueKey(
        'estadoModulo',
        entrenamientoModulo!.inEstado,
      );

    inModulo.value = entrenamientoModulo!.inModulo!;

    await obtenerArchivosRegistrados(
      context,
    );
  }

  Future<void> _onPickFile(
    BuildContext context, {
    required void Function(PlatformFile) onFile,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['*.*'],
      );

      final file = result?.files.firstOrNull;

      if (file != null) {
        if (file.size > (4 * 1024 * 1024) && context.mounted) {
          MensajeValidacionWidget.single(
            'El archivo no debe superar los 4MB',
          ).show(context);
          return;
        }
        onFile(file);
      } else {
        _logger.info('No se seleccionaron archivos');
      }
    } catch (error, stackTrace) {
      _logger.severe('Error al adjuntar documentos', error, stackTrace);
      if (context.mounted) {
        MensajeValidacionWidget.single('Error al adjuntar documentos')
            .show(context);
      }
    }
  }

  Future<void> cargarArchivoControlHoras(BuildContext context) async {
    return _onPickFile(
      context,
      onFile: (file) {
        aaControlHorasFileBytes = file.bytes;
        aaControlHorasController.text = file.name;
        aaControlHorasSeleccionado.value = true;
      },
    );
  }

  Future<void> cargarArchivoExamenTeorico(BuildContext context) async {
    return _onPickFile(
      context,
      onFile: (file) {
        aaExamenTeoricoFileBytes = file.bytes;
        aaExamenTeoricoController.text = file.name;
        aaExamenTeoricoSeleccionado.value = true;
      },
    );
  }

  Future<void> cargarArchivoExamenPractico(BuildContext context) async {
    return _onPickFile(
      context,
      onFile: (file) {
        aaExamenPracticoFileBytes = file.bytes;
        aaExamenPracticoController.text = file.name;
        aaExamenPracticoSeleccionado.value = true;
      },
    );
  }

  Future<void> cargarArchivoOtros(BuildContext context) async {
    return _onPickFile(
      context,
      onFile: (file) {
        aaOtrosFileBytes = file.bytes;
        aaOtrosController.text = file.name;
        aaOtrosSeleccionado.value = true;
      },
    );
  }

  Future<String> registrarArchivoControlHoras(
    BuildContext context,
  ) async {
    try {
      final datosBase64 = base64Encode(aaControlHorasFileBytes!);
      final extension = aaControlHorasController.text.split('.').last;
      final mimeType = _determinarMimeType(extension);

      final response = await archivoService.registrarArchivo(
        key: 0,
        nombre: aaControlHorasController.text,
        extension: extension,
        mime: mimeType,
        datos: datosBase64,
        inTipoArchivo: TipoArchivoModulo.CONTROL_HORAS,
        inOrigen: OrigenArchivo.entrenamientoModulo,
        inOrigenKey: entrenamientoModuloId,
      );

      if (response.success) {
        aaControlHorasSeleccionado.value = false;
        obtenerArchivosRegistrados(
          context,
        );
        _logger.info(
          'Archivo ${aaControlHorasController.text} registrado con éxito',
        );
        return 'Archivo ${aaControlHorasController.text} registrado con éxito';
      } else {
        _logger.info(
          'Error al registrar archivo  ${aaControlHorasController.text}: ${response.message}',
        );
        return 'Error al registrar archivo  ${aaControlHorasController.text}: ${response.message}';
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
      return 'Error al registrar archivos: $e';
    }
  }

  Future<void> registrarArchivoExamenTeorico(
    BuildContext context,
  ) async {
    try {
      final datosBase64 = base64Encode(aaExamenTeoricoFileBytes!);
      final extension = aaExamenTeoricoController.text.split('.').last;
      final mimeType = _determinarMimeType(extension);

      final response = await archivoService.registrarArchivo(
        key: 0,
        nombre: aaExamenTeoricoController.text,
        extension: extension,
        mime: mimeType,
        datos: datosBase64,
        inTipoArchivo: TipoArchivoModulo.EXAMEN_TEORICO,
        inOrigen: OrigenArchivo.entrenamientoModulo,
        inOrigenKey: entrenamientoModuloId,
      );

      if (response.success) {
        aaExamenTeoricoSeleccionado.value = false;
        obtenerArchivosRegistrados(
          context,
        );
        // context.snackbar(
        //   'Exito',
        //   'Archivo subido exitosamente: ${response.message}',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        _logger.info(
          'Archivo ${aaExamenTeoricoController.text} registrado con éxito',
        );
      } else {
        _logger.info(
          'Error al registrar archivo  ${aaExamenTeoricoController.text}: ${response.message}',
        );
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
    }
  }

  Future<void> registrarArchivoExamenPractico(
    BuildContext context,
  ) async {
    try {
      final datosBase64 = base64Encode(aaExamenPracticoFileBytes!);
      final extension = aaExamenPracticoController.text.split('.').last;
      final mimeType = _determinarMimeType(extension);

      final response = await archivoService.registrarArchivo(
        key: 0,
        nombre: aaExamenPracticoController.text,
        extension: extension,
        mime: mimeType,
        datos: datosBase64,
        inTipoArchivo: TipoArchivoModulo.EXAMEN_PRACTICO,
        inOrigen: OrigenArchivo.entrenamientoModulo,
        inOrigenKey: entrenamientoModuloId,
      );

      if (response.success) {
        aaExamenPracticoSeleccionado.value = false;
        obtenerArchivosRegistrados(
          context,
        );
        // context.snackbar(
        //   'Exito',
        //   'Archivo subido exitosamente: ${response.message}',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        _logger.info(
          'Archivo ${aaExamenPracticoController.text} registrado con éxito',
        );
      } else {
        _logger.info(
          'Error al registrar archivo  ${aaExamenPracticoController.text}: ${response.message}',
        );
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
    }
  }

  Future<void> registrarArchivoOtros(
    BuildContext context,
  ) async {
    try {
      final datosBase64 = base64Encode(aaOtrosFileBytes!);
      final extension = aaOtrosController.text.split('.').last;
      final mimeType = _determinarMimeType(extension);

      final response = await archivoService.registrarArchivo(
        key: 0,
        nombre: aaOtrosController.text,
        extension: extension,
        mime: mimeType,
        datos: datosBase64,
        inTipoArchivo: TipoArchivoModulo.OTROS,
        inOrigen: OrigenArchivo.entrenamientoModulo,
        inOrigenKey: entrenamientoModuloId,
      );

      if (response.success) {
        aaOtrosSeleccionado.value = false;
        obtenerArchivosRegistrados(
          context,
        );
        // context.snackbar(
        //   'Exito',
        //   'Archivo subido exitosamente: ${response.message}',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        // );
        _logger.info('Archivo ${aaOtrosController.text} registrado con éxito');
      } else {
        _logger.info(
          'Error al registrar archivo  ${aaOtrosController.text}: ${response.message}',
        );
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
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

  Future<void> obtenerArchivosRegistrados(
    BuildContext context,
  ) async {
    try {
      final response = await archivoService.getFilesByOrigin(
        origin: OrigenArchivo.entrenamientoModulo,
        originKey: entrenamientoModuloId,
      );

      if (!response.success) {
        MensajeValidacionWidget(
          errores: [
            response.message ?? 'Error al obtener archivos',
          ],
        ).show(context);
        return;
      }

      aaControlHorasController.clear();
      aaExamenTeoricoController.clear();
      aaExamenPracticoController.clear();
      aaOtrosController.clear();

      aaControlHorasExiste.value = false;
      aaExamenTeoricoExiste.value = false;
      aaExamenPracticoExiste.value = false;
      aaOtrosExiste.value = false;

      for (final archivo in response.data!) {
        switch (archivo.inTipoArchivo) {
          case TipoArchivoModulo.CONTROL_HORAS:
            aaControlHorasController.text = archivo.nombre;
            aaControlHorasFileBytes = Uint8List.fromList(archivo.datos);
            aaControlHorasExiste.value = true;
            aaControlHorasId.value = archivo.key;
          case TipoArchivoModulo.EXAMEN_TEORICO:
            aaExamenTeoricoFileBytes = Uint8List.fromList(archivo.datos);
            aaExamenTeoricoController.text = archivo.nombre;
            aaExamenTeoricoExiste.value = true;
            aaExamenTeoricoId.value = archivo.key;
          case TipoArchivoModulo.EXAMEN_PRACTICO:
            aaExamenPracticoController.text = archivo.nombre;
            aaExamenPracticoFileBytes = Uint8List.fromList(archivo.datos);
            aaExamenPracticoExiste.value = true;
            aaExamenPracticoId.value = archivo.key;
          case TipoArchivoModulo.OTROS:
            aaOtrosController.text = archivo.nombre;
            aaOtrosFileBytes = Uint8List.fromList(archivo.datos);
            aaOtrosExiste.value = true;
            aaOtrosId.value = archivo.key;
        }
        _logger.info('Archivo ${archivo.nombre} obtenido con éxito');
      }
    } catch (e, stacktrace) {
      _logger.severe('Error al obtener archivos', e, stacktrace);
    }
  }

  bool validarArchivosPorSubir() {
    if (aaControlHorasSeleccionado.value ||
        aaExamenTeoricoSeleccionado.value ||
        aaExamenPracticoSeleccionado.value ||
        aaOtrosSeleccionado.value) {
      _logger
        ..info('Control de horas existe ${aaControlHorasSeleccionado.value}')
        ..info('Examen Teorico existe ${aaExamenTeoricoSeleccionado.value}')
        ..info('Examen Practico existe ${aaExamenPracticoSeleccionado.value}')
        ..info('Otros existe ${aaOtrosSeleccionado.value}');

      return true;
    }
    return false;
  }

  bool validarArchivosObligatorios() {
    if (aaControlHorasExiste.value &&
        aaExamenTeoricoExiste.value &&
        aaExamenPracticoExiste.value) {
      return true;
    }
    return false;
  }

  Future<void> subirArchivos(
    BuildContext context,
  ) async {
    if (aaControlHorasSeleccionado.value) {
      await registrarArchivoControlHoras(
        context,
      );
    }
    if (aaExamenTeoricoSeleccionado.value) {
      await registrarArchivoExamenTeorico(
        context,
      );
    }
    if (aaExamenPracticoSeleccionado.value) {
      await registrarArchivoExamenPractico(
        context,
      );
    }
    if (aaOtrosSeleccionado.value) {
      await registrarArchivoOtros(
        context,
      );
    }
  }

  Future<void> eliminarArchivo(BuildContext context, int archivoId) async {
    try {
      _logger.info('Archivo Id: $archivoId');
      final response = await archivoService.eliminarArchivo(
        key: archivoId,
        nombre: '',
        extension: '',
        mime: '',
        datos: '',
        inTipoArchivo: 0,
        inOrigen: 0,
        inOrigenKey: 0,
      );
      _logger.info('Response: $response');
      if (response.success) {
        context.snackbar(
          'Exito',
          'Archivo eliminado exitosamente: ${response.message}',
        );
        obtenerArchivosRegistrados(
          context,
        );
      } else {
        context.snackbar(
          'Error',
          'No se pudo eliminar el archivo: ${response.message}',
        );
        obtenerArchivosRegistrados(
          context,
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
}
