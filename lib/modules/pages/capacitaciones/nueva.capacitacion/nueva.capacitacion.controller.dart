import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.archivo.dart';
import 'package:sgem/config/api/api.capacitacion.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/config/constants/origen.archivo.dart';
import 'package:sgem/config/constants/tipo.actividad.dart';
import 'package:sgem/modules/pages/capacitaciones/capacitacion.controller.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.initializer.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';

class NuevaCapacitacionController extends GetxController {
  // Controladores de campos de texto
  final TextEditingController codigoMcpController = TextEditingController();
  final TextEditingController dniInternoController = TextEditingController();
  final TextEditingController dniExternoController = TextEditingController();
  final TextEditingController dniEntrenadorController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidoPaternoController =
      TextEditingController();
  final TextEditingController apellidoMaternoController =
      TextEditingController();
  final TextEditingController fechaInicioController = TextEditingController();
  final TextEditingController fechaTerminoController = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaTermino;
  final TextEditingController horasController = TextEditingController();
  final TextEditingController notaTeoriaController = TextEditingController();
  final TextEditingController notaPracticaController = TextEditingController();
  final TextEditingController guardiaController = TextEditingController();
  final TextEditingController entrenadorController = TextEditingController();

  // Variables de selección
  RxBool isInternoSelected = true.obs;

  Rxn<Uint8List?> personalPhoto = Rxn<Uint8List?>();
  final PersonalService personalService = PersonalService();
  var selectedPersonal = Rxn<Personal>();

  var archivosAdjuntos = <Map<String, dynamic>>[].obs;
  final ArchivoService archivoService = ArchivoService();

  // capacitacion service
  final CapacitacionService capacitacionService = CapacitacionService();

  // Función para alternar entre Personal Interno y Externo
  void seleccionarInterno() => isInternoSelected.value = true;
  void seleccionarExterno() => isInternoSelected.value = false;
  final maestroDetalleService = MaestroDetalleService();
  RxInt? idEntrenadorExterno = 0.obs;
  RxString? nombreEntrenadorExterno = ''.obs;
  final List<String> errores = [];

  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();
  final DropdownDataInitializer dataInitializer =
      Get.put(DropdownDataInitializer(
    dropdownController: Get.find<GenericDropdownController>(),
    maestroDetalleService: MaestroDetalleService(),
  ));

  // MODELOS
  EntrenamientoModulo? entrenamientoModulo;
  Personal? personalInterno;
  Personal? personalExterno;

  CapacitacionController capacitacionController =
      Get.find<CapacitacionController>();

  RxBool isLoading = false.obs;
  RxBool isValidate = false.obs;
  RxBool isValidateCategoria = false.obs;

  void _mostrarMensajeGuardado(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const MensajeGuardadoWidget();
      },
    );
  }

  void _mostrarErroresValidacion(BuildContext context, List<String> errores) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MensajeValidacionWidget(errores: errores);
      },
    );
  }

  Future<EntrenamientoModulo?> loadCapacitacion(int capacitacionKey) async {
    try {
      final response =
          await capacitacionService.obtenerCapacitacionPorId(capacitacionKey);
      if (response.success && response.data != null) {
        entrenamientoModulo = response.data;

        isInternoSelected.value = (entrenamientoModulo!.tipoPersona! == 'I');
        idEntrenadorExterno!.value = response.data!.inEntrenador!;

        llenarControladores();
      } else {
        log('Error al obtener datos de capacitación: ${response.message}');
      }
    } catch (e) {
      log('Error al cargar capacitación: $e');
    }
    return null;
  }

  void actualizarOpcionesEmpresaCapacitadora() async {
    final categoriaSeleccionada =
        dropdownController.getSelectedValue('categoria')?.nombre ?? '';

    dropdownController.resetSelection('empresaCapacitadora');
    dropdownController.optionsMap['empresaCapacitadora']?.clear();

    nombreEntrenadorExterno!.value = "";

    if (categoriaSeleccionada == 'Interna') {
      final opcionesInternas =
          dropdownController.getOptionsFromKey('empresaCapacitadoraInterna');
      dropdownController.optionsMap['empresaCapacitadora']
          ?.assignAll(opcionesInternas);
    } else if (categoriaSeleccionada == 'Externa') {
      final opcionesExternas =
          dropdownController.getOptionsFromKey('empresaCapacitadoraExterna');
      dropdownController.optionsMap['empresaCapacitadora']
          ?.assignAll(opcionesExternas);
    }
    sincronizarSeleccion('empresaCapacitadora');
  }

  void sincronizarSeleccion(String key) {
    final opciones = dropdownController.getOptionsFromKey(key);
    final seleccionada = dropdownController.getSelectedValue(key);
    log('Sincronizando selección para $seleccionada');

    if (seleccionada != null && !opciones.contains(seleccionada)) {
      dropdownController.resetSelection(key);
    }
  }

  Future<Personal?> loadPersonalInterno(BuildContext context, String codigoMcp,
      bool validate, bool esEdicion) async {
    if (codigoMcp.isEmpty && validate) {
      _mostrarErroresValidacion(context, ['Por favor ingrese un código MCP']);
      return null;
    }
    try {
      if (!esEdicion) {
        entrenamientoModulo = null;
      }

      final response = await personalService.listarPersonalEntrenamiento(
          codigoMcp: codigoMcp);
      if (response.success && response.data != null) {
        personalInterno = response.data!.first;

        // resetControllers();
        llenarControladores();
        isValidate.value = true;
      } else {
        _mostrarErroresValidacion(
            context, ['No se encontró personal con ese código MCP.']);
      }
    } catch (e) {
      _mostrarErroresValidacion(
          context, ['No se encontró personal con ese código MCP.']);
    }
    return null;
  }

  Future<Personal?> loadPersonalExterno(
      BuildContext context, String dni, bool validate, bool esEdicion) async {
    if (dni.isEmpty && validate) {
      _mostrarErroresValidacion(
          context, ['Por favor ingrese un número de documento.']);
      return null;
    }
    try {
      if (!esEdicion) {
        entrenamientoModulo = null;
      }

      final response =
          await personalService.obtenerPersonalExternoPorNumeroDocumento(dni);

      if (response.success && response.data != null) {
        personalExterno = response.data;
        llenarControladores();
        isValidate.value = true;
      } else {
        _mostrarErroresValidacion(
            context, ['La persona no se encuentra registrada en el sistema.']);
      }
    } catch (e) {
      log('Error al cargar personal externo: $e');
    }
    return null;
  }

  Future<Personal?> loadEntrenadorExterno(
      BuildContext context, String dni, bool validate) async {
    if (dni.isEmpty && validate) {
      _mostrarErroresValidacion(
          context, ['Por favor ingrese un número de documento.']);
      return null;
    }

    //Validar que el usuario no sea el mismo que el capacitador  //101927 - 41258426

    if (dniExternoController.text.length > 0 &&
        dniExternoController.text == dni) {
      _mostrarErroresValidacion(context, [
        'El entrenador no puede ser la misma persona. Por favor, indique otro entrenador..'
      ]);
      return null;
    }

    if (dniInternoController.text.length > 0 &&
        dniInternoController.text == dni) {
      _mostrarErroresValidacion(context, [
        'El entrenador no puede ser la misma persona. Por favor, indique otro entrenador..'
      ]);
      return null;
    }

    try {
      final response =
          await personalService.obtenerPersonalExternoPorNumeroDocumento(dni);

      if (response.success && response.data != null) {
        //personalExterno = response.data;
        idEntrenadorExterno!.value = response.data!.inPersonalOrigen!;
        nombreEntrenadorExterno?.value = [
          response.data?.primerNombre,
          response.data?.segundoNombre,
          response.data?.apellidoPaterno,
          response.data?.apellidoMaterno,
        ].where((element) => element != null && element.isNotEmpty).join(' ');
        log('Nombre del entrenador: $nombreEntrenadorExterno');
        isValidate.value = true;
      } else {
        _mostrarErroresValidacion(
            context, ['La persona no se encuentra registrada en el sistema.']);
      }
    } catch (e) {
      log('Error al cargar personal externo: $e');
    }
    return null;
  }

  String formatoFechaPantalla(DateTime? fecha) {
    if (fecha == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  void llenarControladores() {
    resetControllers();
    if (entrenamientoModulo != null) {
      isValidateCategoria.value = true;

      fechaInicio = entrenamientoModulo!.fechaInicio;
      fechaInicioController.text = formatoFechaPantalla(fechaInicio);
      fechaTermino = entrenamientoModulo!.fechaTermino;
      fechaTerminoController.text = formatoFechaPantalla(fechaTermino);
      horasController.text =
          entrenamientoModulo!.inTotalHoras?.toString() ?? '';

      notaTeoriaController.text = entrenamientoModulo!.inNotaTeorica == 0
          ? ''
          : (entrenamientoModulo!.inNotaTeorica?.toString() ?? '');
      notaPracticaController.text = entrenamientoModulo!.inNotaTeorica == 0
          ? ''
          : (entrenamientoModulo!.inNotaPractica?.toString() ?? '');

      dropdownController.selectValueKey(
          'categoria', entrenamientoModulo!.inCategoria);
      //TODO: OBS
      String nombreEntrenador = '';
      String documentoEntrenador = '';

      if (entrenamientoModulo!.entrenador != null &&
          entrenamientoModulo!.entrenador!.nombre != null &&
          entrenamientoModulo!.entrenador!.nombre!.length > 0) {
        nombreEntrenador =
            entrenamientoModulo!.entrenador!.nombre!.split('|')[1];
        documentoEntrenador =
            entrenamientoModulo!.entrenador!.nombre!.split('|')[0];
      }

      nombreEntrenadorExterno!.value = nombreEntrenador;
      dniEntrenadorController.text = documentoEntrenador;

      dropdownController.selectValueKey(
          'empresaCapacitadora', entrenamientoModulo!.inEmpresaCapacitadora);

      dropdownController.selectValueKey(
          'entrenador', entrenamientoModulo!.inEntrenador);
      dropdownController.selectValueKey(
          'capacitacion', entrenamientoModulo!.inCapacitacion);
    }

    if (isInternoSelected == true) {
      loadPersonalPhoto(personalInterno!.inPersonalOrigen!);
      codigoMcpController.text = personalInterno!.codigoMcp!;
      dniInternoController.text = personalInterno!.numeroDocumento!;
      nombresController.text = personalInterno!.nombreCompleto!;
      apellidoPaternoController.text = personalInterno!.apellidoPaterno!;
      apellidoMaternoController.text = personalInterno!.apellidoMaterno!;
      guardiaController.text = personalInterno!.guardia!.nombre!;
    }

    if (isInternoSelected == false) {
      loadPersonalPhoto(personalExterno!.inPersonalOrigen!);
      nombresController.text =
          '${personalExterno!.primerNombre} ${personalExterno!.segundoNombre}';
      dniExternoController.text = personalExterno!.numeroDocumento!;
      apellidoPaternoController.text = personalExterno!.apellidoPaterno!;
      apellidoMaternoController.text = personalExterno!.apellidoMaterno!;
    }
  }

  Future<void> loadPersonalPhoto(int idOrigen) async {
    try {
      final photoResponse =
          await personalService.obtenerFotoPorCodigoOrigen(idOrigen);

      if (photoResponse.success && photoResponse.data != null) {
        personalPhoto.value = photoResponse.data;
      } else {
        log('Error al cargar la foto: ${photoResponse.message}');
      }
    } catch (e) {
      log('Error al cargar la foto del personal: $e');
    }
  }

  Future<bool?> registrarCapacitacion(
    BuildContext context,
  ) async {
    isLoading.value = true;
    try {
      if (!_validarHoras(context)) {
        return false;
      }

      if (!_validarFechas(context)) {
        return false;
      }

      // Validar que exista el personal interno
      if (isInternoSelected == true && personalInterno == null) {
        _mostrarErroresValidacion(context, ['Por favor busque un personal']);
        return false;
      }

      if (isInternoSelected == false && personalExterno == null) {
        _mostrarErroresValidacion(context, ['Por favor busque un externo']);
        return false;
      }

      if (dropdownController.getSelectedValue('categoria')?.key == 18 &&
          (dniEntrenadorController.text == '' ||
              nombreEntrenadorExterno!.value == '')) {
        //validar perosnal externo y categoria externa
        _mostrarErroresValidacion(
            context, ['Por favor complete todos los campos requeridos.']);
        return false;
      }

      // Validar campos requeridos
      if (!_validarCamposRequeridos()) {
        _mostrarErroresValidacion(
            context, ['Por favor complete todos los campos requeridos.']);
        return false;
      }

      // Validar fechas
      if (fechaInicio == null || fechaTermino == null) {
        _mostrarErroresValidacion(
            context, ['Por favor ingrese fechas válidas.']);
        return false;
      }

      int entrenadorKey;
      String entrenadorNombre;

      if (dropdownController.getSelectedValue('categoria')?.nombre ==
          'Externa') {
        entrenadorKey = idEntrenadorExterno?.value ?? 0;
        entrenadorNombre = nombreEntrenadorExterno?.value ?? '';
      } else {
        entrenadorKey =
            dropdownController.getSelectedValue('entrenador')?.key ?? 0;
        entrenadorNombre =
            dropdownController.getSelectedValue('entrenador')?.nombre ?? '';
      }

      // Crear el modelo de capacitación
      entrenamientoModulo = EntrenamientoModulo()
        ..inTipoActividad = TipoActividad.CAPACITACION
        ..inCapacitacion =
            dropdownController.getSelectedValue('capacitacion')?.key ?? 0
        ..inModulo = 0
        ..modulo = OptionValue(key: 0, nombre: '')
        ..tipoPersona = isInternoSelected == true ? 'I' : 'E'
        ..inPersona = isInternoSelected == true
            ? personalInterno!.key
            : personalExterno!.inPersonalOrigen!
        ..inActividadEntrenamiento = 0
        ..inCategoria =
            dropdownController.getSelectedValue('categoria')?.key ?? 0
        ..inEquipo = 0
        ..equipo = OptionValue(key: 0, nombre: '')
        ..inEntrenador = entrenadorKey
        ..entrenador = OptionValue(key: entrenadorKey, nombre: entrenadorNombre)
        ..inEmpresaCapacitadora =
            dropdownController.getSelectedValue('empresaCapacitadora')?.key ?? 0
        ..inCondicion = 0
        ..condicion = OptionValue(key: 0, nombre: '')
        ..inEstado = 0
        ..estadoEntrenamiento = OptionValue(key: 0, nombre: '')
        ..fechaInicio = fechaInicio
        ..fechaTermino = fechaTermino
        ..inTotalHoras = int.parse(horasController.text)
        ..inNotaTeorica = notaTeoriaController.text.length == 0
            ? null
            : int.parse(notaTeoriaController.text)
        ..inNotaPractica = notaPracticaController.text.length == 0
            ? null
            : int.parse(notaPracticaController.text);

      // Validar que las notas estén en el rango correcto (0-99)
      if (!_validarRangoNotas()) {
        _mostrarErroresValidacion(context, [
          'Las notas deben estar entre 0 y 99',
        ]);
        return false;
      }

      Logger('Enviando datos de registro: ${entrenamientoModulo!.toJson()}');

      final response =
          await capacitacionService.registrarCapacitacion(entrenamientoModulo!);
      log('Response: ${response.data}');
      if (response.success) {
        log('Capacitación registrada exitosamente');
        _mostrarMensajeGuardado(context);
        capacitacionController.clearFields();
        dniEntrenadorController.clear();
        nombreEntrenadorExterno?.value = '';
        capacitacionController.buscarCapacitaciones();
        return true;
      } else {
        log('Error al registrar la capacitación: ${response.message}');
        context.snackbar(
          'Error',
          'No se pudo registrar la capacitación: ${response.message}',
        );
        return false;
      }
    } catch (e) {
      log('Error al registrar la capacitación: $e');
      context.snackbar(
        'Error',
        'Ocurrió un error inesperado al registrar la capacitación',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool?> actualizarCapacitacion(
    BuildContext context,
  ) async {
    isLoading.value = true;
    if (entrenamientoModulo == null) {
      log('Error: entrenamientoModulo es null');
      return false;
    }

    try {
      // Validar campos requeridos
      if (!_validarCamposRequeridos()) {
        _mostrarErroresValidacion(context, [
          'Por favor complete todos los campos requeridos',
        ]);
        return false;
      }

      if (dropdownController.getSelectedValue('categoria')?.key == 18 &&
          (dniEntrenadorController.text == '' ||
              nombreEntrenadorExterno!.value == '')) {
        //validar perosnal externo y categoria externa
        _mostrarErroresValidacion(
            context, ['Por favor complete todos los campos requeridos.']);
        return false;
      }

      if (!_validarHoras(context)) {
        return false;
      }

      if (!_validarFechas(context)) {
        return false;
      }
      int entrenadorKey;
      String entrenadorNombre;

      if (dropdownController.getSelectedValue('categoria')?.nombre ==
          'Externa') {
        entrenadorKey = idEntrenadorExterno?.value ?? 0;
        entrenadorNombre = nombreEntrenadorExterno?.value ?? '';
      } else {
        entrenadorKey =
            dropdownController.getSelectedValue('entrenador')?.key ?? 0;
        entrenadorNombre =
            dropdownController.getSelectedValue('entrenador')?.nombre ?? '';
      }
      // Crear una copia del modelo para actualizarlo
      final capacitacionActualizada = EntrenamientoModulo()
        ..key = entrenamientoModulo!.key
        ..inTipoActividad = TipoActividad.CAPACITACION
        ..inCapacitacion =
            dropdownController.getSelectedValue('capacitacion')?.key ?? 0
        ..inModulo = 0
        ..modulo = OptionValue(key: 0, nombre: '')
        ..tipoPersona = isInternoSelected == true ? 'I' : 'E'
        // ..inPersona = isInternoSelected == true
        //     ? personalInterno!.key
        //     : personalExterno!.inPersonalOrigen!
        ..inPersona = isInternoSelected == true
            ? personalInterno!.key
            : entrenamientoModulo!.inPersona! // personalExterno!.id
        ..inActividadEntrenamiento = 0
        ..inCategoria = dropdownController.getSelectedValue('categoria')?.key
        ..inEquipo = 0
        ..equipo = OptionValue(key: 0, nombre: '')
        ..inEntrenador = entrenadorKey
        ..entrenador = OptionValue(key: entrenadorKey, nombre: entrenadorNombre)
        ..inEmpresaCapacitadora =
            dropdownController.getSelectedValue('empresaCapacitadora')?.key
        ..inCondicion = 0
        ..condicion = OptionValue(key: 0, nombre: '')
        ..inEstado = 0
        ..estadoEntrenamiento = OptionValue(key: 0, nombre: '')
        ..fechaInicio = fechaInicio
        ..fechaTermino = fechaTermino
        ..inTotalHoras = int.parse(horasController.text)
        ..inNotaTeorica = notaTeoriaController.text.length == 0
            ? null
            : int.parse(notaTeoriaController.text)
        ..inNotaPractica = notaPracticaController.text.length == 0
            ? null
            : int.parse(notaPracticaController.text);

      if (!_validarRangoNotas()) {
        _mostrarErroresValidacion(context, [
          'Las notas deben estar entre 0 y 99',
        ]);
        return false;
      }

      log('Enviando actualización: ${capacitacionActualizada.toJson()}');

      final response = await capacitacionService
          .actualizarCapacitacion(capacitacionActualizada);

      if (response.success) {
        await registrarArchivos(entrenamientoModulo!.key!);
        log('Capacitación actualizada exitosamente');
        _mostrarMensajeGuardado(context);
        capacitacionController.clearFields();
        dniEntrenadorController.clear();
        nombreEntrenadorExterno?.value = '';
        capacitacionController.buscarCapacitaciones();
        return true;
      } else {
        log('Error en la respuesta del servidor: ${response.message}');
        context.snackbar(
          'Error',
          'No se pudo actualizar la capacitación: ${response.message}',
        );
        return false;
      }
    } catch (e) {
      log('Error al actualizar la capacitación: $e');
      context.snackbar(
        'Error',
        'Ocurrió un error al actualizar la capacitación',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool _validarRangoNotas() {
    try {
      if (notaTeoriaController.text.length == 0 &&
          notaPracticaController.text.length == 0) {}

      final notaTeorica = notaTeoriaController.text.length == 0
          ? 0
          : int.parse(notaTeoriaController.text);
      final notaPractica = notaPracticaController.text.length == 0
          ? 0
          : int.parse(notaPracticaController.text);

      return (notaTeoriaController.text.length == 0 ||
              (notaTeorica >= 0 && notaTeorica <= 99)) &&
          (notaPracticaController.text.length == 0 ||
              notaPractica >= 0 && notaPractica <= 99);
    } catch (e) {
      return false;
    }
  }

  bool _validarFechas(
    BuildContext context,
  ) {
    if (fechaInicio == null || fechaTermino == null) {
      _mostrarErroresValidacion(context, ['Por favor ingrese fechas válidas.']);
      return false;
    }

    if (fechaTermino!.isBefore(fechaInicio!)) {
      _mostrarErroresValidacion(context,
          ['La fecha de término debe ser mayor o igual a la fecha de inicio.']);
      return false;
    }

    return true;
  }

  bool _validarHoras(
    BuildContext context,
  ) {
    final horasText = horasController.text.trim();

    if (horasText.isEmpty) {
      _mostrarErroresValidacion(context, ['El campo de horas es obligatorio']);
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(horasText)) {
      _mostrarErroresValidacion(
          context, ['El campo de horas debe contener solo números']);
      return false;
    }

    if (horasText.length > 3) {
      _mostrarErroresValidacion(
          context, ['El campo de horas no puede exceder los 3 caracteres']);
      return false;
    }

    return true;
  }

  bool _validarCamposRequeridos() {
    return fechaInicioController.text.isNotEmpty &&
        fechaTerminoController.text.isNotEmpty &&
        horasController.text.isNotEmpty &&
        // notaTeoriaController.text.isNotEmpty &&
        // notaPracticaController.text.isNotEmpty &&
        dropdownController.getSelectedValue('categoria') != null &&
        dropdownController.getSelectedValue('capacitacion') != null &&
        dropdownController.getSelectedValue('empresaCapacitadora') != null;
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

  Future<void> adjuntarDocumentos(
    BuildContext context,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );

      if (result != null) {
        if (!validateFileSize(result.files.first)) {
          // mostrarErroresValidacion(context, [
          //   'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.'
          // ]);

          // context.snackbar(
          //   'Error',
          //   'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.',
          //   snackPosition: SnackPosition.BOTTOM,
          //   backgroundColor: Colors.red,
          //   colorText: Colors.white,
          // );
          mostrarErroresValidacion(context, [
            'El archivo seleccionado superó el peso máximo de 4MB. Por favor, seleccione otro.'
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

  Future<void> registrarArchivos(int keyCapacitacion) async {
    try {
      var archivosNuevos = archivosAdjuntos
          .where((archivo) => archivo['nuevo'] == true)
          .toList();
      for (var archivo in archivosNuevos) {
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
            inTipoArchivo: OrigenArchivo.capacitacion,
            inOrigen: TipoActividad.CAPACITACION,
            inOrigenKey: keyCapacitacion,
          );

          if (response.success) {
            log('Archivo ${archivo['nombre']} registrado con éxito');
            archivo['nuevo'] = false;
          } else {
            log('Error al registrar archivo ${archivo['nombre']}: ${response.message}');
          }
        } catch (e) {
          log('Error al registrar archivo ${archivo['nombre']}: $e');
        }
      }
    } catch (e) {
      log('Error al registrar archivos: $e');
    }
  }

  String _determinarMimeType(String extension) {
    switch (extension) {
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

  void removerArchivo(String nombreArchivo) {
    archivosAdjuntos.removeWhere((archivo) =>
        archivo['nombre'] == nombreArchivo && archivo['nuevo'] == true);
    log('Archivo $nombreArchivo eliminado');
  }

  Future<void> descargarArchivo(
      BuildContext context, Map<String, dynamic> archivo) async {
    try {
      String nombreArchivo = archivo['nombre'];
      String extension = archivo['extension'];
      String datosBase64 = archivo['datos'];
      Uint8List archivoBytes = base64Decode(datosBase64);

      if (nombreArchivo.endsWith('.$extension')) {
        nombreArchivo = nombreArchivo.substring(
            0, nombreArchivo.length - extension.length - 1);
      }
      MimeType mimeType = _determinarMimeType2(extension);
      await FileSaver.instance.saveFile(
        name: nombreArchivo,
        bytes: archivoBytes,
        ext: extension,
        mimeType: mimeType,
      );
    } catch (e) {
      log('Error al descargar el archivo $e');
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

  Future<void> eliminarArchivo(
      BuildContext context, Map<String, dynamic> archivo) async {
    try {
      final response = await archivoService.eliminarArchivo(
        key: archivo['key'],
        nombre: archivo['nombre'],
        extension: archivo['extension'],
        mime: archivo['mime'],
        datos: archivo['datos'],
        inTipoArchivo: OrigenArchivo.capacitacion,
        inOrigen: TipoActividad.CAPACITACION,
        inOrigenKey: archivo['inOrigenKey'],
      );

      if (response.success) {
        archivosAdjuntos.clear();
        await obtenerArchivosRegistrados(
            idOrigen: OrigenArchivo.capacitacion,
            idOrigenKey: archivo['inOrigenKey']);
      } else {
        context.snackbar(
          'Error',
          'No se pudo eliminar el archivo: ${response.message}',
        );
      }
    } catch (e) {
      log('Error al eliminar el archivo: $e');
      context.snackbar(
        'Error',
        'No se pudo eliminar el archivo: $e',
      );
    }
  }

  Future<void> obtenerArchivosRegistrados(
      {required int idOrigen, int? idOrigenKey, int? idTipoArchivo}) async {
    try {
      final response = await archivoService.obtenerArchivosPorOrigen(
        idOrigen: idOrigen,
        idOrigenKey: idOrigenKey!,
        idTipoArchivo: idTipoArchivo!,
      );
      log('Response: ${response.data}');
      if (response.success && response.data != null) {
        archivosAdjuntos.clear();
        for (var archivo in response.data!) {
          List<int> datos = List<int>.from(archivo['Datos']);
          Uint8List archivoBytes = Uint8List.fromList(datos);

          archivosAdjuntos.add({
            'key': archivo['Key'],
            'nombre': archivo['Nombre'],
            'extension': archivo['Extension'],
            'mime': archivo['Mime'],
            'datos': base64Encode(archivoBytes),
            'inOrigenKey': idOrigenKey,
            'nuevo': false,
          });

          log('Archivo ${archivo['Nombre']} obtenido con éxito');
        }
      } else {
        log('Error al obtener archivos: ${response.message}');
      }
    } catch (e) {
      log('Error al obtener archivos: $e');
    }
  }

  void resetControllers() {
    personalPhoto.value = null;
    codigoMcpController.clear();
    dniInternoController.clear();
    dniExternoController.clear();
    nombresController.clear();
    isValidate.value = false;
    isValidateCategoria.value = false;
    apellidoPaternoController.clear();
    apellidoMaternoController.clear();
    entrenadorController.clear();
    fechaInicioController.clear();
    fechaTerminoController.clear();
    horasController.clear();
    notaTeoriaController.clear();
    notaPracticaController.clear();
    guardiaController.clear();
    dropdownController.resetAllSelections();
    archivosAdjuntos.clear();
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
