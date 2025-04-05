import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.entrenamiento.dart';
import 'package:sgem/config/api/api.modulo.maestro.dart';
import 'package:sgem/config/api/response.handler.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.entrenamiento/entrenamiento.nuevo.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.modulo/entrenamiento.modulo.nuevo.dart';
import 'package:sgem/shared/controller/mail_controller.dart';
import 'package:sgem/shared/dialogs/success_dialog.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';

class EntrenamientoPersonalController extends GetxController {
  RxList<EntrenamientoModulo> trainingList = <EntrenamientoModulo>[].obs;
  final EntrenamientoService entrenamientoService = EntrenamientoService();
  final ModuloMaestroService moduloMaestroService = ModuloMaestroService();
  RxMap<int, RxList<EntrenamientoModulo>> modulosPorEntrenamiento =
      <int, RxList<EntrenamientoModulo>>{}.obs;
  Rxn<EntrenamientoModulo> selectedTraining = Rxn<EntrenamientoModulo>();
  RxBool isLoading = false.obs;

  void setSelectedTrainingKey(EntrenamientoModulo? training) {
    selectedTraining.value = training;
  }

  List<int> assetsNotAvailable() {
    return trainingList
        .where((e) => !(e.isParaliced ?? false))
        .map((e) => e.inEquipo!)
        .toList();
  }

  static final Logger _logger = Logger('EntrenamientoPersonalController');

  Future<void> onEditModule(
      BuildContext context, EntrenamientoModulo modulo, int personal) async {
    final success = await EntrenamientoModuloNuevo(
      eModulo: modulo,
      inPersona: modulo.inPersona,
      inEntrenamientoModulo: modulo.key,
      inEntrenamiento: modulo.inActividadEntrenamiento,
      isEdit: true,
    ).show(context);

    if (success != null && success) {
      await fetchTrainings(context, personal);
    }
  }

  Future<void> onCreateModule(
    BuildContext context,
    EntrenamientoModulo entrenamiento,
    int personal,
  ) async {
    _logger.info('Entrenamiento: ${entrenamiento.key!}');
    final response =
        await entrenamientoService.obtenerUltimoModuloPorEntrenamiento(
      entrenamiento.key!,
    );

    final ultimoModulo = response.data!;
    final inModulo = ultimoModulo.inModulo;

    if (inModulo == 4) {
      return const MensajeValidacionWidget(
        errores: [
          'No se puede agregar más módulos',
        ],
      ).show(context);
    }

    _logger.info('Ultimo modulo: ${ultimoModulo.inModulo}');
    if (inModulo != null &&
        inModulo >= 1 &&
        !(ultimoModulo.isCompleted ?? false)) {
      _logger.info(
        'Estado ultimo modulo: ${ultimoModulo.estadoEntrenamiento?.nombre}',
      );
      return MensajeValidacionWidget.single(
        'No se puede agregar un NUEVO MODULO mientras '
        'el módulo anterior no haya sido COMPLETADO.',
      ).show(context);
    }

    final success = await EntrenamientoModuloNuevo(
      eModulo: entrenamiento,
      inEntrenamiento: entrenamiento.key,
      inPersona: entrenamiento.inPersona,
    ).show(context);

    if (success != null && success) {
      await fetchTrainings(context, personal);
    }
  }

  Future<void> fetchTrainings(BuildContext context, int personId) async {
    try {
      // isLoading.value = true;
      _logger.info('Entrenamiento Controller: $personId');

      final response =
          await entrenamientoService.listarEntrenamientoPorPersona(personId);

      if (!response.success || response.data == null) {
        return MensajeValidacionWidget.single(
          response.message ?? 'No se pudieron cargar los entrenamientos',
        ).show(context);
      }

      trainingList.value = response.data!
          .map(
            (json) =>
                EntrenamientoModulo.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      _logger.info('Entrenamiento: ${trainingList.length}');

      for (final training in trainingList) {
        await _fetchAndCombineUltimoModulo(training);
      }

      await _fetchModulosParaEntrenamientos(
        context,
      );
    } catch (e, stackTrace) {
      _logger.severe(
        'Error al cargar los entrenamientos',
        e,
        stackTrace,
      );
      return MensajeValidacionWidget.single(
        'Ocurrió un problema al cargar los entrenamientos',
      ).show(context);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAndCombineUltimoModulo(
    EntrenamientoModulo training,
  ) async {
    try {
      final response = await entrenamientoService
          .obtenerUltimoModuloPorEntrenamiento(training.key!);
      if (response.success && response.data != null) {
        final ultimoModulo = response.data!;
        if (ultimoModulo.key != null) {
          training.actualizarConUltimoModulo(ultimoModulo);
        }

        trainingList.refresh();
      } else {
        _logger.info('Error al obtener el último módulo: ${response.message}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error al obtener el último módulo', e, stackTrace);
    }
  }

  Future<void> _fetchModulosParaEntrenamientos(
    BuildContext context,
  ) async {
    for (final entrenamiento in trainingList) {
      try {
        final response = await moduloMaestroService
            .listarModulosPorEntrenamiento(entrenamiento.key!);
        if (response.success) {
          modulosPorEntrenamiento[entrenamiento.key!] =
              RxList<EntrenamientoModulo>(response.data!);
        }
      } catch (e) {
        _logger.info('Error al cargar los módulos: $e');
        context.snackbar(
            'Error', 'Ocurrió un problema al cargar los módulos, $e');
      }
    }
  }

  List<EntrenamientoModulo> obtenerModulosPorEntrenamiento(int trainingKey) {
    return modulosPorEntrenamiento[trainingKey]?.toList() ?? [];
  }

  Future<EntrenamientoModulo?> obtenerUltimoEntrenamientoPorPersona(
    BuildContext context,
    int personaId,
  ) async {
    try {
      final response = await entrenamientoService
          .obtenerUltimoEntrenamientoPorPersona(personaId);

      _logger.info('Entrenamiento: ${response.data}');
      if (response.success) {
        final entrenamientoModulo = response.data!;

        return entrenamientoModulo;
      }
    } catch (e) {
      _logger.info('Error al cargar los módulos: $e');
      context.snackbar(
          'Error', 'Ocurrió un problema al cargar los módulos, $e');
      return null;
    }
    return null;
  }

  Future<bool> actualizarEntrenamiento(
    BuildContext context,
    EntrenamientoModulo training,
  ) async {
    try {
      final response = await entrenamientoService.updateEntrenamiento(training);

      if (response.success) {
        final index = trainingList.indexWhere((t) => t.key == training.key);
        if (index != -1) {
          trainingList[index] = training;
          trainingList.refresh();
        }
        final controller = Get.put(EntrenamientoNuevoController());
        await controller.registrarArchivos(training.key!);
        controller.archivosAdjuntos.clear();
        //controller.documentoAdjuntoNombre.value = '';
        //controller.documentoAdjuntoBytes.value = null;
        await const SuccessDialog().show(context);

        if (training.isAuthorized ?? false) {
          unawaited(
            Get.find<MailController>().mailNEFIN(
              training,
              personal:
                  Get.find<PersonalSearchController>().selectedPersonal.value!,
              modulos: modulosPorEntrenamiento[training.key!]!,
            ),
          );
        }
        return true;
      } else {
        MensajeValidacionWidget(
          errores: [
            response.message ?? 'No se pudo actualizar el entrenamiento',
          ],
        ).show(context);
        return false;
      }
    } catch (e) {
      const MensajeValidacionWidget(
        errores: ['Ocurrió un problema al actualizar el entrenamiento'],
      ).show(context);
      return false;
    }
  }

  Future<bool> eliminarEntrenamiento(
      BuildContext context, EntrenamientoModulo training) async {
    try {
      final response =
          await entrenamientoService.eliminarEntrenamiento(training);
      if (response.success) {
        trainingList.remove(training);
        return true;
      } else {
        context.snackbar(
          'Error',
          'No se pudo eliminar el entrenamiento',
        );
        return false;
      }
    } catch (e) {
      context.snackbar(
        'Error',
        'Ocurrió un problema al eliminar el entrenamiento',
      );
      return false;
    }
  }

  Future<bool> eliminarModulo(
      BuildContext context, EntrenamientoModulo modulo) async {
    try {
      final response = await moduloMaestroService.eliminarModulo(modulo);
      if (response.success) {
        await fetchModulosPorEntrenamiento(
            context, modulo.inActividadEntrenamiento!);
        return true;
      } else {
        context.snackbar(
          'Error',
          response.message ?? 'No se pudo eliminar el módulo',
        );
        return false;
      }
    } catch (e) {
      context.snackbar(
        'Error',
        'Ocurrió un problema al eliminar el módulo',
      );
      return false;
    }
  }

  Future<void> fetchModulosPorEntrenamiento(
      BuildContext context, int entrenamientoKey) async {
    try {
      final response = await moduloMaestroService
          .listarModulosPorEntrenamiento(entrenamientoKey);
      if (response.success) {
        modulosPorEntrenamiento[entrenamientoKey] =
            RxList<EntrenamientoModulo>(response.data!);
        modulosPorEntrenamiento.refresh();
      } else {
        context.snackbar(
            'Error', 'No se pudieron cargar los módulos actualizados');
      }
    } catch (e) {
      context.snackbar('Error', 'Ocurrió un problema al cargar los módulos');
    }
  }

  //selectedTraining
  Future<void> ShowTraining(int id) async {
//
    ResponseHandler<List<dynamic>> trainingPerson =
        await entrenamientoService.listarEntrenamientoPorPersona(id);

    trainingList.value = trainingPerson.data!
        .map(
          (json) => EntrenamientoModulo.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}
