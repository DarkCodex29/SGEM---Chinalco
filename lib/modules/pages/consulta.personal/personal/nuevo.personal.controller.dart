import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/config/api/api.personal.dart';
import 'package:sgem/config/api/api.archivo.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/config/constants/origen.archivo.dart';
import 'package:sgem/config/constants/tipo.actividad.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/shared/controller/mail_controller.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';

class NuevoPersonalController extends GetxController {
  final TextEditingController dniController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController puestoTrabajoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController apellidoPaternoController =
      TextEditingController();
  final TextEditingController apellidoMaternoController =
      TextEditingController();
  final TextEditingController gerenciaController = TextEditingController();
  final TextEditingController fechaIngresoController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController categoriaLicenciaController =
      TextEditingController();
  final TextEditingController codigoLicenciaController =
      TextEditingController();
  final TextEditingController fechaIngresoMinaController =
      TextEditingController();
  final TextEditingController fechaRevalidacionController =
      TextEditingController();
  final TextEditingController restriccionesController = TextEditingController();

  final PersonalService personalService = PersonalService();

  final PersonalSearchController personalSearchController =
      Get.find<PersonalSearchController>();

  Logger _logger = Logger('NuevoPersonalController');

  Personal? personalData;
  Rxn<Uint8List?> personalPhoto = Rxn<Uint8List?>();
  RxInt estadoPersonalKey = 0.obs;
  RxString estadoPersonalNombre = ''.obs;
  RxBool isOperacionMina = false.obs;
  RxBool isZonaPlataforma = false.obs;

  //var documentoAdjuntoNombre = ''.obs;
  //var documentoAdjuntoBytes = Rxn<Uint8List>();
  var archivosAdjuntos = <Map<String, dynamic>>[].obs;

  DateTime? fechaIngreso;
  DateTime? fechaIngresoMina;
  DateTime? fechaRevalidacion;

  final ArchivoService archivoService = ArchivoService();

  RxBool isLoadingDni = false.obs;
  RxBool isSaving = false.obs;
  List<String> errores = [];
  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();

  final maestroDetalleService = MaestroDetalleService();

  Future<void> loadPersonalPhoto(int idOrigen) async {
    // personalPhoto.value = null;
    try {
      final photoResponse = await personalService.getPersonalPhoto(idOrigen);

      if (photoResponse.success) {
        personalPhoto.value = photoResponse.data;
      } else {
        _logger.info('Error al cargar la foto: ${photoResponse.message}');
        personalPhoto.value = null;
      }
    } catch (error, stackTrace) {
      personalPhoto.value = null;
      _logger.severe(
        'Error al cargar la foto del personal $idOrigen',
        error,
        stackTrace,
      );
    }
  }

  Future<void> buscarPersonalPorDni(BuildContext context, String dni) async {
    if (dni.isEmpty) {
      _mostrarErroresValidacion(context, ['Ingrese un DNI válido.']);
      resetControllers();
      return;
    }
    try {
      isLoadingDni.value = true;
      final responseListar = await personalService.listarPersonalEntrenamiento(
        numeroDocumento: dni,
      );
      if (responseListar.success &&
          responseListar.data != null &&
          responseListar.data!
              .where((personal) => personal.eliminado != 'S')
              .isNotEmpty) {
        _mostrarErroresValidacion(
            context, ['La persona ya se encuentra registrada en el sistema.']);
        resetControllers();
        return;
      }

      final responseBuscar = await personalService.buscarPersonalPorDni(dni);
      Personal personalData1 = responseBuscar.data!;
      if (personalData1.estado!.key == 96) {
        _mostrarErroresValidacion(context, ['La persona se encuentra cesada.']);
        resetControllers();
        return;
      }
      if (responseBuscar.success && responseBuscar.data != null) {
        personalData = responseBuscar.data;
        llenarControladoresPrincipal(personalData!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal no encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
        resetControllers();
      }
    } catch (e) {
      _logger.info('Error inesperado al buscar el personal: $e');
    } finally {
      isLoadingDni.value = false;
    }
  }

  DateTime? parseDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(rawDate);
    } catch (e) {
      _logger.info('Error al parsear la fecha: $e');
      return null;
    }
  }

  void llenarControladoresPrincipal(Personal personalData) {
    loadPersonalPhoto(personalData.inPersonalOrigen!);
    dniController.text = personalData.numeroDocumento ?? '';
    nombresController.text =
        '${personalData.primerNombre ?? ''} ${personalData.segundoNombre ?? ''}';
    puestoTrabajoController.text = personalData.cargo?.nombre ?? '';
    codigoController.text = personalData.codigoMcp ?? '';
    apellidoPaternoController.text = personalData.apellidoPaterno ?? '';
    apellidoMaternoController.text = personalData.apellidoMaterno ?? '';
    gerenciaController.text = personalData.gerencia ?? '';
    areaController.text = personalData.area ?? '';
    fechaIngreso = personalData.fechaIngreso;
    fechaIngresoController.text = fechaIngreso != null
        ? DateFormat('dd/MM/yyyy').format(fechaIngreso!)
        : '';
    estadoPersonalKey.value = personalData.estado?.key ?? 0;
    estadoPersonalNombre.value = personalData.estado?.nombre ?? 'Sin estado';
  }

  void llenarControladores(Personal personalData) {
    loadPersonalPhoto(personalData.inPersonalOrigen!);
    dniController.text = personalData.numeroDocumento ?? '';
    nombresController.text =
        '${personalData.primerNombre ?? ''} ${personalData.segundoNombre ?? ''}';
    puestoTrabajoController.text = personalData.cargo?.nombre ?? '';
    codigoController.text = personalData.codigoMcp ?? '';
    apellidoPaternoController.text = personalData.apellidoPaterno ?? '';
    apellidoMaternoController.text = personalData.apellidoMaterno ?? '';
    gerenciaController.text = personalData.gerencia ?? '';
    areaController.text = personalData.area ?? '';
    //categoriaLicenciaController.text = personalData.licenciaCategoria ?? '';
    dropdownController.selectValueKey(
        'categoriaLicencia', personalData.licenciaCategoria!.key);
    codigoLicenciaController.text = personalData.licenciaConducir ?? '';
    restriccionesController.text = personalData.restricciones ?? '';
    fechaIngreso = personalData.fechaIngreso;
    fechaIngresoController.text = fechaIngreso != null
        ? DateFormat('dd/MM/yyyy').format(fechaIngreso!)
        : '';

    fechaIngresoMina = personalData.fechaIngresoMina;
    fechaIngresoMinaController.text = fechaIngresoMina != null
        ? DateFormat('dd/MM/yyyy').format(fechaIngresoMina!)
        : '';

    fechaRevalidacion = personalData.fechaRevalidacion;
    fechaRevalidacionController.text = fechaRevalidacion != null
        ? DateFormat('dd/MM/yyyy').format(fechaRevalidacion!)
        : '';

    if (personalData.guardia != null && personalData.guardia!.key != 0) {
      dropdownController.selectValueKey(
          'guardiaRegistro', personalData.guardia!.key);
    } else {
      dropdownController.selectValueKey('guardiaRegistro', null);
    }

    isOperacionMina.value = personalData.operacionMina == 'S';
    isZonaPlataforma.value = personalData.zonaPlataforma == 'S';
    estadoPersonalKey.value = personalData.estado?.key ?? 0;
    estadoPersonalNombre.value = personalData.estado?.nombre ?? 'Sin estado';
    obtenerArchivosRegistrados(personalData.key!);
  }

  Future<bool> gestionarPersona({
    required String accion,
    String? motivoEliminacion,
    required BuildContext context,
  }) async {
    errores.clear();
    _logger.info('Gestionando persona con la acción: $accion');
    bool esValido = validate(context);
    if (!esValido && accion != 'eliminar') {
      _mostrarErroresValidacion(context, errores);
      return false;
    }
    try {
      isSaving.value = true;
      String obtenerPrimerNombre(String nombres) {
        List<String> nombresSplit = nombres.split(' ');
        return nombresSplit.isNotEmpty ? nombresSplit.first : '';
      }

      String obtenerSegundoNombre(String nombres) {
        List<String> nombresSplit = nombres.split(' ');
        return nombresSplit.length > 1 ? nombresSplit[1] : '';
      }

      String verificarTexto(String texto) {
        return texto.isNotEmpty ? texto : '';
      }

      _logger.info('Fecha mina: ${fechaIngresoMina}');
      _logger.info('Fecha ingreso: ${fechaIngreso}');
      personalData!
        ..primerNombre = obtenerPrimerNombre(nombresController.text)
        ..segundoNombre = obtenerSegundoNombre(nombresController.text)
        ..apellidoPaterno = verificarTexto(apellidoPaternoController.text)
        ..apellidoMaterno = verificarTexto(apellidoMaternoController.text)
        ..cargo = OptionValue(
          nombre: verificarTexto(puestoTrabajoController.text),
        )
        ..fechaIngreso = fechaIngreso
        ..licenciaConducir = verificarTexto(codigoLicenciaController.text)
        ..licenciaCategoria = OptionValue(
          key: dropdownController.getSelectedValue('categoriaLicencia')?.key ??
              0,
          nombre: personalData!.licenciaCategoria?.nombre,
        )
        ..fechaIngresoMina = fechaIngresoMina
        ..fechaRevalidacion = fechaRevalidacion
        ..guardia = OptionValue(
          key: dropdownController.getSelectedValue('guardiaRegistro')?.key ?? 0,
          nombre: personalData!.guardia?.nombre,
        )
        ..operacionMina = isOperacionMina.value ? 'S' : 'N'
        ..zonaPlataforma = isZonaPlataforma.value ? 'S' : 'N'
        //..eliminado = 'S'
        ..restricciones = verificarTexto(restriccionesController.text);

      if (accion == 'eliminar') {
        personalData!
          ..eliminado = 'S'
          ..motivoElimina = motivoEliminacion ?? 'Sin motivo'
          ..usuarioElimina = 'usuarioActual';
      } else if (accion == 'registrar') {
        final confirmation = await ConfirmDialog().show(context);
        if (!(confirmation ?? false)) return false;
      }

      final response = await _accionPersona(accion);

      if (response.success) {
        await registrarArchivos(dniController.text);
        if (accion == 'registrar' || accion == 'actualizar') {
          _mostrarMensajeGuardado(context);
          resetControllers();
          personalSearchController.searchPersonal();
        }
        return true;
      } else {
        _logger.info('Acción $accion fallida: ${response.message}');
        return false;
      }
    } catch (error, stackTrace) {
      _logger.severe('Error al gestionar la persona', error, stackTrace);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<ResponseHandler<bool>> _accionPersona(String accion) async {
    _logger.info('Personal: ${personalData.toString()}');
    switch (accion) {
      case 'registrar':
        _logger.info('Registrar');
        final response = await personalService.registratePersona(personalData!);

        if (response.success) {
          try {
            final personalResponse =
                await personalService.buscarPersonalPorDni(dniController.text);

            if (personalResponse.success && personalResponse.data != null) {
              final personal = personalResponse.data;
              Get.find<MailController>().mailNRPER(
                personal!,
                dropdownController.getSelectedValue('guardiaRegistro')!.nombre!,
              );
            }
          } catch (e, stackTrace) {
            _logger.severe('Error al enviar el correo', e, stackTrace);
          }
        }

        return response;
      case 'actualizar':
        _logger.info('Actualizar');
        return personalService.actualizarPersona(personalData!);
      case 'eliminar':
        _logger.info('Eliminar');
        return personalService.eliminarPersona(personalData!);
      default:
        throw Exception('Acción no reconocida: $accion');
    }
  }

//VALIDACIONES
  bool validate(BuildContext context) {
    _logger.info('Validando la fecha de ingreso a mina');
    _logger.info('Fecha de ingreso mina: $fechaIngresoMina');

    // Validación de fecha de ingreso a mina
    if (fechaIngresoMina == null) {
      errores.add('Debe seleccionar una fecha de ingreso a la mina.');
    } else {
      if (fechaIngresoMina!.isBefore(fechaIngreso!)) {
        _logger.info('Fecha de ingreso mina: $fechaIngresoMina');
        errores.add('La FECHA INGRESO MINA debe ser mayor a la FECHA INGRESO.');
      }
    }

    // Validación de fecha de revalidación
    if (fechaRevalidacion == null) {
      errores.add('Debe seleccionar una fecha de revalidación.');
    } else {
      if (fechaRevalidacion!.isBefore(DateTime.now())) {
        errores
            .add('La FECHA DE REVALIDACIÓN debe ser mayor a la FECHA ACTUAL.');
      }
      if (fechaRevalidacion!.isBefore(fechaIngresoMina!)) {
        errores.add(
            'La FECHA DE REVALIDACIÓN debe ser mayor a la FECHA DE INGRESO MINA.');
      }
    }

    // Validación de código de licencia
    if (codigoLicenciaController.text.isEmpty ||
        codigoLicenciaController.text.length != 9) {
      errores
          .add('El código de licencia debe tener 9 caracteres alfanuméricos.');
    }

    // Validación de categoría de licencia
    if (dropdownController.getSelectedValue('categoriaLicencia')?.nombre ==
        null) {
      errores.add('Debe seleccionar una categoría de licencia.');
    }

    // Validación de guardia
    if (dropdownController.getSelectedValue('guardiaRegistro')?.nombre ==
        null) {
      errores.add('Debe seleccionar una guardia.');
    }

    // Validación de restricciones
    if (restriccionesController.text.length > 100) {
      errores
          .add('El campo de restricciones no debe exceder los 100 caracteres.');
    }

    // Si hay errores, retornamos falso
    if (errores.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> adjuntarDocumentos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx'],
      );

      if (result != null) {
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

  void removerArchivo(String nombreArchivo) {
    archivosAdjuntos.removeWhere((archivo) =>
        archivo['nombre'] == nombreArchivo && archivo['nuevo'] == true);
    _logger.info('Archivo $nombreArchivo eliminado');
  }

  Future<void> registrarArchivos(String dni) async {
    try {
      final personalResponse = await personalService
          .listarPersonalEntrenamiento(numeroDocumento: dni);

      if (personalResponse.success && personalResponse.data!.isNotEmpty) {
        int origenKey = personalResponse.data!.last.key!;
        _logger.info('Key del personal obtenida: $origenKey');
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
              inTipoArchivo: OrigenArchivo.persona,
              inOrigen: TipoActividad.ENTRENAMIENTO, // 1: TABLA Personal
              inOrigenKey: origenKey,
            );

            if (response.success) {
              _logger.info('Archivo ${archivo['nombre']} registrado con éxito');
              archivo['nuevo'] = false;
            } else {
              _logger.info(
                  'Error al registrar archivo ${archivo['nombre']}: ${response.message}');
            }
          } catch (e) {
            _logger.info('Error al registrar archivo ${archivo['nombre']}: $e');
          }
        }
      } else {
        _logger.info('Error al obtener la key del personal');
      }
    } catch (e) {
      _logger.info('Error al registrar archivos: $e');
    }
  }

  Future<void> obtenerArchivosRegistrados(int idOrigenKey) async {
    try {
      final response = await archivoService.obtenerArchivosPorOrigen(
        idOrigen: TipoActividad.ENTRENAMIENTO, // 1: TABLA Personal
        idOrigenKey: idOrigenKey,
        idTipoArchivo: OrigenArchivo.persona,
      );

      _logger.info('Response: ${response.data}');
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

          _logger.info('Archivo ${archivo['Nombre']} obtenido con éxito');
        }
      } else {
        _logger.info('Error al obtener archivos: ${response.message}');
      }
    } catch (e) {
      _logger.info('Error al obtener archivos: $e');
    }
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
      _logger.info('Error al descargar el archivo $e');
      context.snackbar(
        'Error',
        'No se pudo descargar el archivo: $e',
      );
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
        inTipoArchivo: OrigenArchivo.persona,
        inOrigen: TipoActividad.ENTRENAMIENTO,
        inOrigenKey: archivo['inOrigenKey'],
      );

      if (response.success) {
        obtenerArchivosRegistrados(archivo['inOrigenKey']);
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

  void resetControllers() {
    dniController.clear();
    nombresController.clear();
    puestoTrabajoController.clear();
    codigoController.clear();
    apellidoPaternoController.clear();
    apellidoMaternoController.clear();
    gerenciaController.clear();
    fechaIngresoController.clear();
    areaController.clear();
    //categoriaLicenciaController.clear();
    codigoLicenciaController.clear();
    fechaIngresoMinaController.clear();
    fechaRevalidacionController.clear();
    restriccionesController.clear();
    personalPhoto.value = null;
    isOperacionMina.value = false;
    isZonaPlataforma.value = false;
    estadoPersonalKey.value = 0;
    estadoPersonalNombre.value = '';
    //documentoAdjuntoNombre.value = '';
    //documentoAdjuntoBytes.value = null;
    personalData = null;
    dropdownController.resetAllSelections();
  }

  Future<void> showPersonalPhoto(int idOrigen) async {
    ResponseHandler<Uint8List> photoResponse =
        await personalService.obtenerFotoPorCodigoOrigen(
      idOrigen,
    );
    personalPhoto.value = photoResponse.data;
  }
}
