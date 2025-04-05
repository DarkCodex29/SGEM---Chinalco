import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/puestos_nivel/puestos_nivel_controller.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.entrenamiento/entrenamiento.nuevo.controller.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/controller/mail_controller.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/dialogs/warning_dialog.dart';
import 'package:sgem/shared/models/maestro_detalle.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class EntrenamientoNuevoModal extends StatefulWidget {
  EntrenamientoNuevoModal({
    required this.data,
    super.key,
    this.isEdit = false,
    this.training,
    this.lastModulo,
    this.assetsNotAvailable,
  });

  final Personal data;
  final bool isEdit;
  final EntrenamientoModulo? training;
  final int? lastModulo;
  final List<int>? assetsNotAvailable;

  Future<EntrenamientoModulo?> show(BuildContext context) async =>
      showDialog<EntrenamientoModulo>(
        context: context,
        builder: (context) => this,
      );

  @override
  State<EntrenamientoNuevoModal> createState() =>
      _EntrenamientoNuevoModalState();
}

class _EntrenamientoNuevoModalState extends State<EntrenamientoNuevoModal> {
  @override
  void initState() {
    Logger('EntrenamientoNuevoModal').info(
      '''
      training: ${widget.training}
      isEdit: ${widget.isEdit},
      lastModulo: ${widget.lastModulo},
      assetsNotAvailable: ${widget.assetsNotAvailable}
      ''',
    );
    controller.clearFields();
    if (widget.training != null)
      controller.completeFields(context, widget.training!);
    super.initState();
  }

  final EntrenamientoNuevoController controller =
      Get.put(EntrenamientoNuevoController());

  final double paddingVertical = 20;

  bool get isAuthorized => widget.training?.isAuthorized ?? false;

  bool get isParaliced => widget.training?.isParaliced ?? false;

  Widget content(BuildContext context) {
    Logger('EntrenamientoNuevoModal').info('lastModulo: ${widget.lastModulo}');
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEquipoAndDateRow(context),
          const SizedBox(height: 10),
          _buildConditionAndDateRow(
            context,
          ),
          if (widget.isEdit) ...[
            const SizedBox(height: 10),
            _buildStateAndObservationsRow(),
            const SizedBox(height: 10),
            _buildObservationsRow(),
            const SizedBox(height: 10),
            //adjuntarArchivoText(),
            adjuntarDocumentoPDF(
              context,
              controller,
              readOnly: isParaliced || isAuthorized,
            ),
          ],
          const SizedBox(height: 20),
          customButtonsCancelAndAcept(
            context,
            () => registerTraining(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipoAndDateRow(BuildContext context) {
    final readOnly = widget.lastModulo != null && widget.lastModulo! > 1;

    return Row(
      children: [
        Expanded(
          child: MaestraAppDropdown(
            label: 'Equipo',
            options: (ctr) => ctr.assets.toDetalle(),
            filterOptions: (assets) {
              if (widget.assetsNotAvailable != null) {
                if (widget.isEdit) {
                  widget.assetsNotAvailable!.removeWhere(
                    (e) => e == widget.training!.equipo!.key,
                  );
                }
                assets.removeWhere(
                    (e) => widget.assetsNotAvailable!.contains(e.key));
              }
            },
            controller: controller.equipoController,
            isRequired: true,
            readOnly: isParaliced || (readOnly || isAuthorized),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: CustomTextField(
            label: 'Fecha de inicio:',
            controller: controller.fechaInicioController,
            isRequired: true,
            icon: const Icon(
              Icons.calendar_month,
              color: AppTheme.primaryColor,
            ),
            readOnly: isParaliced || isAuthorized,
            onIconPressed: () async {
              final fechaInicial =
                  (controller.fechaInicioController.text.isNotEmpty)
                      ? DateFormat('dd/MM/yyyy')
                          .parse(controller.fechaInicioController.text, true)
                      : null;

              final nuevaFecha = await _selectDate(context, fechaInicial);
              if (nuevaFecha != null) {
                controller.fechaInicio = nuevaFecha;
                controller.fechaInicioController.text =
                    DateFormat('dd/MM/yyyy').format(nuevaFecha);
              }
            },
            onChanged: (value) {
              if (controller.fechaInicioController.text.isNotEmpty) {
                try {
                  controller.fechaInicio = DateFormat('dd/MM/yyyy')
                      .parse(controller.fechaInicioController.text);
                } catch (_) {
                  controller.fechaInicio = null;
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConditionAndDateRow(
    BuildContext context,
  ) {
    final readOnly = widget.lastModulo != null && widget.lastModulo! > 1;
    Logger('EntrenamientoNuevoModal').info(readOnly);
    return Row(
      children: [
        Expanded(
          child: SimpleAppDropdown(
            label: 'Condición',
            options: controller.condicionDetalle
                .map((e) => (e.key!, e.value))
                .toList(),
            initialValue: widget.training?.condicion?.key,
            // controller.condicionSelected.value?.key,
            // selectedValue: controller.condicionSelectedBinding,
            onChanged: (int? value) {
              controller.condicionSelectedBinding.set(
                value == null
                    ? null
                    : controller.condicionDetalle
                        .firstWhere((e) => e.key == value),
              );
            },
            readOnly: isParaliced || (readOnly || isAuthorized),
            // isSearchable: false,
            isRequired: true,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomTextField(
              label: 'Fecha de termino:',
              readOnly: isParaliced || isAuthorized,
              controller: controller.fechaTerminoController,
              //isRequired: true,
              icon: const Icon(
                Icons.calendar_month,
                color: AppTheme.primaryColor,
              ),
              onIconPressed: () async {
                final fechaTermino =
                    (controller.fechaTerminoController.text.isNotEmpty)
                        ? DateFormat('dd/MM/yyyy')
                            .parse(controller.fechaTerminoController.text, true)
                        : null;

                final nuevaFecha = await _selectDate(context, fechaTermino);
                if (nuevaFecha != null) {
                  controller.fechaTermino = nuevaFecha;
                  controller.fechaTerminoController.text =
                      DateFormat('dd/MM/yyyy').format(nuevaFecha);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateAndObservationsRow() {
    return Row(
      children: [
        Expanded(
          child: MaestraAppDropdown(
            label: 'Estado Entrenamiento',
            options: (ctr) => ctr.trainStatus.toOptionValue(),
            controller: controller.trainStatus,
            readOnly: isParaliced,
            filterOptions: switch (
                widget.training?.estadoEntrenamiento?.nombre) {
              'Paralizado' => (estados) =>
                  estados.removeWhere((e) => e.nombre == 'Autorizado'),
              'Autorizado' => (estados) =>
                  estados.removeWhere((e) => e.nombre == 'Entrenando'),
              _ => null,
            },
            isRequired: true,
          ),
        ),
        const SizedBox(width: 20),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _buildObservationsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            maxLines: 2,
            label: 'Observaciones',
            controller: controller.observacionesEntrenamiento,
            readOnly: isParaliced,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger('EntrenamientoNuevoModal').info(
      'key: ${widget.training?.key}, isEdit: ${widget.isEdit}, '
      'isAuthorized: $isAuthorized',
    );
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          minWidth: 300,
          minHeight: 200,
          maxHeight: widget.isEdit ? 600 : 350,
        ),
        child: Obx(
          () {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isParaliced
                            ? 'Entrenamiento Detalle'
                            : widget.isEdit
                                ? 'Editar Entrenamiento'
                                : 'Nuevo Entrenamiento',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (!isParaliced)
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                ),
                // Cuerpo del modal
                Expanded(
                  child: (controller.isLoading.value)
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: content(context),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _validateTraining(BuildContext context) {
    final errores = <String>[];

    final fechaInicio = DateFormat('dd/MM/yyyy')
        .tryParse(controller.fechaInicioController.text);
    if (fechaInicio == null) {
      errores.add('Por favor, selecciona la fecha de inicio.');
    }

    final fechaTermino = DateFormat('dd/MM/yyyy')
        .tryParse(controller.fechaTerminoController.text);
    if (fechaTermino != null && fechaInicio != null) {
      if (fechaTermino.isBefore(fechaInicio)) {
        errores.add(
          'La fecha de término no puede ser anterior a la fecha de inicio.',
        );
      }
    }

    if (controller.condicionSelected.value == null) {
      errores.add('Por favor, selecciona la condición.');
    }

    final equipo = controller.equipoController.selectedOption as Detalle?;
    if (equipo == null) {
      errores.add('Por favor, selecciona el equipo.');
    }

    final estadoEntrenamientoKey =
        widget.isEdit && controller.trainStatus.value != null
            ? controller.trainStatus.value!
            : 0;

    final observaciones = controller.observacionesEntrenamiento.text;

    // if its changing to 'Paralizado'
    if (widget.training?.isParaliced == false &&
        estadoEntrenamientoKey == TrainingStatus.paraliced.key) {
      if (observaciones.isEmpty) {
        errores.add('Ingresar el motivo de la paralización');
      }
    }

    if (errores.isNotEmpty) {
      MensajeValidacionWidget(errores: errores).show(context);
      return false;
    }

    return true;
  }

  Future<bool?> _nivelValidation(
    BuildContext context,
  ) async {
    final equipo = controller.equipoController.selectedOption! as Detalle;
    if (widget.isEdit && widget.training!.equipo?.key == equipo.key)
      return null;

    final nivel = Get.find<PuestosNivelController>()
        .puestosNivelResultados
        .firstWhereOrNull(
          (e) => e.puesto.key == widget.data.cargo!.key && e.activo == 'S',
        )
        ?.nivel;

    Logger('EntrenamientoNuevoModal').info(
      'puesto: ${widget.data.cargo?.key} nivel: $nivel, '
      'equipo.nivel: ${equipo.detalleRelacion}',
    );

    if (equipo.detalleRelacion?.key == nivel?.key) return null;

    final confirm = await const WarningDialog(
      title: 'Advertencia',
      text: 'Se está asignando un entrenamiento a un equipo donde su '
          'nivel de complejidad no corresponde al puesto del trabajador',
    ).show(context);

    Logger('EntrenamientoNuevoModal').info('confirm: $confirm');
    if (confirm ?? false) {
      unawaited(
          Get.find<MailController>().mailNECOM(widget.data, equipo.nombre));
      return true;
    }

    return false;
  }

  Future<void> _onUpdate(
    BuildContext context,
    EntrenamientoModulo newTraining,
  ) async {
    final valid = await _nivelValidation(
      context,
    );

    if (valid == false) {
      return;
    } else if (valid == null) {
      final confirmation = await const ConfirmDialog(
        title: '¿Estas seguro de guardar los datos?',
      ).show(context);

      if (!(confirmation ?? false)) return;
    }

    final trainingPersonalController =
        Get.find<EntrenamientoPersonalController>();

    final refreshed = await trainingPersonalController.actualizarEntrenamiento(
        context, newTraining);

    if (refreshed) {
      if (context.mounted) Navigator.pop(context);
      await trainingPersonalController.fetchTrainings(
          context, widget.data.key!);
    }
  }

  Future<void> _onRegister(
    BuildContext context,
    EntrenamientoModulo newTraining,
  ) async {
    final valid = await _nivelValidation(
      context,
    );

    if (valid == false) {
      return;
    } else if (valid == null) {
      final confirmation = await const ConfirmDialog(
        title: '¿Estas seguro de guardar los datos?',
      ).show(context);

      if (!(confirmation ?? false)) return;
    }

    final trainingPersonalController =
        Get.find<EntrenamientoPersonalController>();

    final isSuccess = await controller.registertraining(context, newTraining);

    if (!isSuccess) return;

    if (context.mounted) Navigator.pop(context);

    final train = await trainingPersonalController
        .obtenerUltimoEntrenamientoPorPersona(context, widget.data.key!);

    if (train != null) {
      unawaited(
        Get.find<MailController>().mailNEPER(train, personal: widget.data),
      );
    }
  }

  Future<void> registerTraining(BuildContext context) async {
    if (!_validateTraining(context)) return;

    final fechaInicio = DateFormat('dd/MM/yyyy')
        .tryParse(controller.fechaInicioController.text);
    final fechaTermino = DateFormat('dd/MM/yyyy')
        .tryParse(controller.fechaTerminoController.text);
    final estadoEntrenamientoKey =
        !widget.isEdit ? 0 : controller.trainStatus.value ?? 0;
    final condicion = controller.condicionSelected.value!;

    final observaciones = controller.observacionesEntrenamiento.text;

    final newModulo = EntrenamientoModulo(
      key: widget.isEdit
          ? widget.training!.key
          : 0, // Usar la key existente si es edición
      inTipoActividad: 1,
      inCapacitacion: 0,
      inModulo: 0,
      modulo: const OptionValue(key: 0, nombre: ''),
      tipoPersona: '',
      inPersona: widget.data.key,
      inActividadEntrenamiento: 0,
      inCategoria: 0,
      inEquipo: controller.equipoController.value,
      equipo: controller.equipoController.selectedOption,
      // OptionValue(key: controller.equipoController.value, nombre: ''),
      inEntrenador: 0,
      entrenador: const OptionValue(key: 0, nombre: ''),
      inEmpresaCapacitadora: 0,
      inCondicion: controller.condicionSelected.value!.key,
      condicion: OptionValue(key: condicion.key, nombre: condicion.value),
      fechaInicio: fechaInicio,
      fechaTermino: fechaTermino,
      inNotaTeorica: 0,
      inNotaPractica: 0,
      inTotalHoras: 0,
      inHorasAcumuladas: 0,
      inHorasMinestar: 0,
      inEstado: estadoEntrenamientoKey,
      estadoEntrenamiento: OptionValue(key: estadoEntrenamientoKey, nombre: ''),
      comentarios: '',
      eliminado: '',
      motivoEliminado: '',
      observaciones: observaciones,
    );

    Get.put(EntrenamientoPersonalController());

    await (widget.isEdit ? _onUpdate : _onRegister)(context, newModulo);
  }

  Widget customButtonsCancelAndAcept(
    BuildContext context,
    VoidCallback onSave,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            controller.clearFieldFechas();
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Cerrar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        if (!isParaliced) ...[
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}

Widget adjuntarDocumentoPDF(
  BuildContext context,
  EntrenamientoNuevoController controller, {
  required bool readOnly,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(Icons.attach_file, color: Colors.grey),
          SizedBox(width: 10),
          Text('Archivos adjuntos:'),
          SizedBox(width: 10),
          Text(
            '(Archivos adjuntos peso máx: 4MB c/u)',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Obx(() {
        if (controller.isLoadingFiles.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.archivosAdjuntos.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.archivosAdjuntos.map((archivo) {
              return Container(
                width: 400,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: archivo['nuevo'] == true
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        archivo['nombre'] as String,
                        style: TextStyle(
                          color: archivo['nuevo'] == true
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Row(
                      children: [
                        if (archivo['nuevo'] == false)
                          IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.descargarArchivo(context, archivo);
                            },
                          ),
                        if (!readOnly)
                          IconButton(
                            icon: Icon(
                              archivo['nuevo'] == true
                                  ? Icons.cancel
                                  : Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              if (archivo['nuevo'] == true) {
                                // Remover archivo adjuntado recientemente
                                controller.removerArchivo(
                                  archivo['nombre'] as String,
                                );
                              } else {
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDeleteWidget(
                                      itemName: archivo['nombre'] as String,
                                      entityType: 'archivo',
                                      onConfirm: () {
                                        controller.eliminarArchivo(
                                            context, archivo);
                                        Navigator.pop(context);
                                      },
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'No hay archivos adjuntos.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          );
        }
      }),
      const SizedBox(height: 10),
      if (!readOnly)
        TextButton.icon(
          onPressed: () => controller.adjuntarDocumentos(context),
          icon: const Icon(Icons.attach_file, color: Colors.blue),
          label: const Text(
            'Adjuntar Documento',
            style: TextStyle(color: Colors.blue),
          ),
        ),
    ],
  );
}

Future<DateTime?> _selectDate(
  BuildContext context,
  DateTime? initialDate,
) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  return picked;
}
