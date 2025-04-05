import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.modulo/entrenamiento.modulo.nuevo.controller.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/custom.text.fromfield.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';

class EntrenamientoModuloNuevo extends StatelessWidget {
  EntrenamientoModuloNuevo({
    super.key,
    this.eModulo,
    this.isEdit = false,
    this.inEntrenamientoModulo,
    this.inEntrenamiento,
    this.inPersona,
    this.isView = false,
    this.moduloKey,
  });

  final EntrenamientoModuloNuevoController controller =
      EntrenamientoModuloNuevoController();

  final EntrenamientoModulo? eModulo;
  final bool isEdit;
  final int? inEntrenamientoModulo;
  final int? inEntrenamiento;
  final int? inPersona;
  final bool isView;
  final int? moduloKey;

  @override
  Widget build(BuildContext context) {
    controller
      ..isEdit = isEdit
      ..isView = isView;

    if (inEntrenamientoModulo != null) {
      controller.obtenerModuloPorId(
          context, inEntrenamiento!, inEntrenamientoModulo!);
    } else {
      controller.nuevoModulo(context, inEntrenamiento!);
    }

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: AlignmentDirectional.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            width: 800,
            height: (isEdit || isView) ? 920 : 620,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x33000000),
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModalTitulo(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPrimeraFila(),
                          _buildSegundaFila(context),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildTerceraFila(context),
                          const SizedBox(
                            height: 20,
                          ),
                          if (isEdit || isView)
                            _buildSeccionAdjuntos(
                              context,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBotones(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> show(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: this,
        );
      },
    );
  }

  Widget _buildAdjuntoRow(
    String titulo,
    TextEditingController controller,
    VoidCallback onPressed,
    VoidCallback onRemove,
    RxBool archivoSeleccionado,
    VoidCallback onUpload,
    VoidCallback onDelete,
    RxBool archivoExiste, {
    VoidCallback? onDownload,
  }) {
    return Row(
      children: [
        Text(titulo),
        const SizedBox(width: 10),
        IconButton(
          tooltip: 'Adjuntar archivo',
          onPressed: onPressed,
          icon: const Icon(Icons.attach_file, color: Colors.grey),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextFormField(
            label: 'Archivo',
            controller: controller,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 10),
        Obx(() {
          if (archivoSeleccionado.value) {
            return IconButton(
              tooltip: 'Quitar archivo',
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            );
          }
          return const SizedBox(
            width: 0,
          );
        }),
        const SizedBox(width: 10),
        Obx(() {
          if (!archivoExiste.value && archivoSeleccionado.value) {
            return IconButton(
              tooltip: 'Subir archivo',
              icon: const Icon(Icons.upload_rounded, color: Colors.blueAccent),
              onPressed: onUpload,
            );
          }
          return const SizedBox(
            width: 0,
          );
        }),
        Obx(() {
          if (archivoExiste.value) {
            return IconButton(
              tooltip: 'Descargar archivo',
              icon: const Icon(
                Icons.download,
                color: Colors.blue,
                size: 20,
              ),
              onPressed: onDownload,
            );
          }
          return const SizedBox(
            width: 0,
          );
        }),
        Obx(() {
          if (archivoExiste.value && isEdit) {
            return IconButton(
              tooltip: 'Elimnar archivo',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            );
          }
          return const SizedBox(
            width: 0,
          );
        }),
      ],
    );
  }

  Widget _buildBotones(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          if (isView)
            const SizedBox(
              width: 0,
            )
          else
            ElevatedButton(
              onPressed: () async {
                final success = await _handleButtonPress(
                  context,
                );
                if (success) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: Obx(() {
                return controller.isSaving.value
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white),
                      );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildHoraSeccion(BuildContext context) {
    final modulo = eModulo?.inModulo ?? moduloKey;
    Logger('EntrenamientoModuloNuevo').info('Modulo: $modulo');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Obx(() {
              return CustomTextField(
                label: 'Total horas módulo',
                controller: controller.totalHorasModuloController.value,
                keyboardType: TextInputType.number,
                isReadOnly: true,
              );
            }),
            CustomTextField(
              label: 'Horas acumuladas',
              controller: controller.horasAcumuladasController,
              icon: const Icon(Icons.more_time),
              isReadOnly: isView,
            ),
            Visibility(
              visible: modulo == 3 || modulo == 4,
              child: CustomTextField(
                label: 'Horas minestar',
                controller: controller.horasMinestarController,
                icon: const Icon(Icons.lock_clock_outlined),
                isReadOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTitulo(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF051367),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Obx(() {
                return controller.isLoadingModulo.value
                    ? const SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        controller.tituloModal.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      );
              }),
            ),
            InkWell(
              onTap: Navigator.of(context).pop,
              child: const Icon(Icons.close, size: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotaSeccion(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            CustomTextField(
              label: 'Teórico',
              controller: controller.notaTeoricaController,
              isReadOnly: isView,
            ),
            CustomTextField(
              label: 'Práctico',
              controller: controller.notaPracticaController,
              isReadOnly: isView,
            ),
            CustomTextField(
              label: 'Fecha de examen:',
              controller: controller.fechaExamenController,
              icon: const Icon(Icons.calendar_month),
              onIconPressed: isView
                  ? null
                  : () async {
                      controller.fechaExamen = await _selectDate(context);
                      controller.fechaExamenController.text =
                          DateFormat('dd/MM/yyyy')
                              .format(controller.fechaExamen!);
                    },
              isReadOnly: isView,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimeraFila() {
    return Row(
      children: [
        Expanded(
          child: CustomDropdownGlobal(
            labelText: 'Entrenador',
            dropdownKey: 'entrenador',
            hintText: 'Responsable',
            noDataHintText: 'No se encontraron entrenadores',
            controller: controller.dropdownController,
            isReadOnly: isView,
            isRequired: true,
          ),
        ),
        const SizedBox(width: 20),
        if (isEdit || isView)
          Expanded(
            child: CustomDropdownGlobal(
              labelText: 'Estado de módulo',
              dropdownKey: 'estadoModulo',
              hintText: 'Estado',
              noDataHintText: 'No se encontraron estados de módulos',
              controller: controller.dropdownController,
              isReadOnly: isView,
            ),
          )
        else
          const Expanded(
            child: SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildSeccionAdjuntos(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.attach_file, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'Archivos adjuntos:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '(Archivos adjuntos peso máx: 4MB c/u)',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        _buildAdjuntoRow(
          'Control de horas',
          controller.aaControlHorasController,
          () => controller.cargarArchivoControlHoras(context),
          () async {
            if (controller.aaControlHorasSeleccionado.value) {
              controller.aaControlHorasController.clear();
              controller.aaControlHorasSeleccionado.value = false;
            }
          },
          controller.aaControlHorasSeleccionado,
          () async {
            if (controller.aaControlHorasExiste.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Ya existe un archivo subido para CONTROL DE HORAS. Debe eliminar el anterior para poder subir uno nuevo.',
                    ],
                  );
                },
              );
              return;
            }

            if (!controller.aaControlHorasSeleccionado.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Debe seleccionar un archivo para poder subirlo.',
                    ],
                  );
                },
              );
              return;
            }
            controller.registrarArchivoControlHoras(
              context,
            );
          },
          () async {
            if (controller.aaControlHorasExiste.value) {
              controller.eliminarArchivo(
                  context, controller.aaControlHorasId.value);
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: ['No hay archivo para eliminar.'],
                  );
                },
              );
            }
          },
          controller.aaControlHorasExiste,
          onDownload: () {
            controller.descargarArchivo(
              context,
              controller.aaControlHorasFileBytes!,
              nombreArchivo: controller.aaControlHorasController.text,
            );
          },
        ),
        _buildAdjuntoRow(
          'Examen Teórico',
          controller.aaExamenTeoricoController,
          () => controller.cargarArchivoExamenTeorico(context),
          () async {
            if (controller.aaExamenTeoricoSeleccionado.value) {
              controller.aaExamenTeoricoController.clear();
              controller.aaExamenTeoricoSeleccionado.value = false;
            }
          },
          controller.aaExamenTeoricoSeleccionado,
          () async {
            if (controller.aaExamenTeoricoExiste.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Ya existe un archivo subido para EXAMEN TEORICO. Debe eliminar el anterior para poder subir uno nuevo.',
                    ],
                  );
                },
              );
              return;
            }

            if (!controller.aaExamenTeoricoSeleccionado.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Debe seleccionar un archivo para poder subirlo.',
                    ],
                  );
                },
              );
              return;
            }
            controller.registrarArchivoExamenTeorico(
              context,
            );
          },
          () async {
            if (controller.aaExamenTeoricoExiste.value) {
              controller.eliminarArchivo(
                  context, controller.aaExamenTeoricoId.value);
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: ['No hay archivo para eliminar.'],
                  );
                },
              );
            }
          },
          controller.aaExamenTeoricoExiste,
          onDownload: () {
            controller.descargarArchivo(
              context,
              controller.aaExamenTeoricoFileBytes!,
              nombreArchivo: controller.aaExamenTeoricoController.text,
            );
          },
        ),
        _buildAdjuntoRow(
          'Examen Práctico',
          controller.aaExamenPracticoController,
          () => controller.cargarArchivoExamenPractico(context),
          () {
            if (controller.aaExamenPracticoSeleccionado.value) {
              controller.aaExamenPracticoController.clear();
              controller.aaExamenPracticoSeleccionado.value = false;
            }
          },
          controller.aaExamenPracticoSeleccionado,
          () async {
            if (controller.aaExamenPracticoExiste.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Ya existe un archivo subido para EXAMEN PRACTICO. Debe eliminar el anterior para poder subir uno nuevo.',
                    ],
                  );
                },
              );
              return;
            }

            if (!controller.aaExamenPracticoSeleccionado.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Debe seleccionar un archivo para poder subirlo.',
                    ],
                  );
                },
              );
              return;
            }
            controller.registrarArchivoExamenPractico(
              context,
            );
          },
          () async {
            if (controller.aaExamenPracticoExiste.value) {
              controller.eliminarArchivo(
                  context, controller.aaExamenPracticoId.value);
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: ['No hay archivo para eliminar.'],
                  );
                },
              );
            }
          },
          controller.aaExamenPracticoExiste,
          onDownload: () {
            controller.descargarArchivo(
              context,
              controller.aaExamenPracticoFileBytes!,
              nombreArchivo: controller.aaExamenPracticoController.text,
            );
          },
        ),
        _buildAdjuntoRow(
          'Otros',
          controller.aaOtrosController,
          () => controller.cargarArchivoOtros(context),
          () async {
            if (controller.aaOtrosSeleccionado.value) {
              controller.aaOtrosController.clear();
              controller.aaOtrosSeleccionado.value = false;
            }
          },
          controller.aaOtrosSeleccionado,
          () async {
            if (controller.aaOtrosExiste.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Ya existe un archivo subido para OTROS. Debe eliminar el anterior para poder subir uno nuevo.',
                    ],
                  );
                },
              );
              return;
            }

            if (!controller.aaOtrosSeleccionado.value) {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: [
                      'Debe seleccionar un archivo para poder subirlo.',
                    ],
                  );
                },
              );
              return;
            }
            controller.registrarArchivoOtros(
              context,
            );
          },
          () async {
            if (controller.aaOtrosExiste.value) {
              controller.eliminarArchivo(context, controller.aaOtrosId.value);
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return const MensajeValidacionWidget(
                    errores: ['No hay archivo para eliminar.'],
                  );
                },
              );
            }
          },
          controller.aaOtrosExiste,
          onDownload: () {
            controller.descargarArchivo(
              context,
              controller.aaOtrosFileBytes!,
              nombreArchivo: controller.aaOtrosController.text,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSegundaFila(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: 'Fecha de inicio:',
            controller: controller.fechaInicioController,
            isRequired: true,
            icon: const Icon(Icons.calendar_month),
            onIconPressed: isView
                ? null
                : () async {
                    controller.fechaInicio = await _selectDate(context);
                    controller.fechaInicioController.text =
                        DateFormat('dd/MM/yyyy')
                            .format(controller.fechaInicio!);
                  },
            isReadOnly: isView,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomTextField(
            label: 'Fecha de termino:',
            controller: controller.fechaTerminoController,
            icon: const Icon(Icons.calendar_month),
            onIconPressed: isView
                ? null
                : () async {
                    final val = await _selectDate(context);
                    controller.fechaTermino = val;

                    controller.fechaTerminoController.text = val != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(controller.fechaTermino!)
                        : '';
                  },
            isReadOnly: isView,
          ),
        ),
      ],
    );
  }

  Widget _buildTerceraFila(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNotaSeccion(context),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: _buildHoraSeccion(context),
        ),
      ],
    );
  }

  Future<bool> _handleButtonPress(
    BuildContext context,
  ) async {
    controller.isSaving.value = true;
    final isModuloCompleto = _isEstadoModuloCompleto();
    if (isEdit) {
      if (isModuloCompleto && !controller.validarArchivosObligatorios()) {
        _mostrarErrores(context, [
          'No se puede cambiar el estado del modulo a COMPLETO.',
          if (!controller.aaControlHorasExiste.value) 'Falta CONTROL DE HORAS',
          if (!controller.aaExamenTeoricoExiste.value) 'Falta EXAMEN TEORICO',
          if (!controller.aaExamenPracticoExiste.value) 'Falta EXAMEN PRACTICO',
          if (!controller.horasAcumuladasController.value.text.isNotEmpty)
            'Falta HORAS ACUMULADAS',
        ]);
        controller.isSaving.value = false;
        return false;
      }
    }

    final success = await controller.registrarModulo(context);
    if (success) {
      await controller.subirArchivos(
        context,
      );
    }
    controller.isSaving.value = false;
    return success;
  }

  bool _isEstadoModuloCompleto() {
    final selectedValue =
        controller.dropdownController.getSelectedValue('estadoModulo');
    return selectedValue != null &&
        selectedValue.nombre?.toLowerCase() == 'completo';
  }

  void _mostrarErrores(BuildContext context, List<String> errores) {
    showDialog(
      context: context,
      builder: (context) {
        return MensajeValidacionWidget(errores: errores);
      },
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return picked;
  }
}
