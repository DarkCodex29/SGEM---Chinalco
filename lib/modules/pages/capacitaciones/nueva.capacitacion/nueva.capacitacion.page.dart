import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/constants/origen.archivo.dart';
import 'package:sgem/config/constants/tipo.actividad.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/capacitaciones/nueva.capacitacion/nueva.capacitacion.controller.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';

class NuevaCapacitacionPage extends StatefulWidget {
  final bool isEditMode;
  final bool isViewing;
  final int? capacitacionKey;
  final String? dni;
  final String? codigoMcp;
  final VoidCallback onCancel;

  NuevaCapacitacionPage({
    super.key,
    required this.isEditMode,
    required this.isViewing,
    this.dni,
    this.codigoMcp,
    this.capacitacionKey,
    required this.onCancel,
  });

  @override
  State<NuevaCapacitacionPage> createState() => _NuevaCapacitacionPageState();
}

class _NuevaCapacitacionPageState extends State<NuevaCapacitacionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCapacitacion(context);
    });
  }

  final NuevaCapacitacionController controller =
      Get.put(NuevaCapacitacionController());

  void _initializeCapacitacion(
    BuildContext context,
  ) async {
    controller.isInternoSelected.value = true;

    if (widget.isEditMode || widget.isViewing) {
      await controller.loadCapacitacion(widget.capacitacionKey!);

      final categoriaSeleccionada =
          controller.dropdownController.getSelectedValue('categoria')?.nombre ??
              '';
      controller.actualizarOpcionesEmpresaCapacitadora();

      if (categoriaSeleccionada == 'Interna') {
        controller.actualizarOpcionesEmpresaCapacitadora();
      } else if (categoriaSeleccionada == 'Externa') {
        controller.actualizarOpcionesEmpresaCapacitadora();
      }

      if (controller.isInternoSelected.value) {
        await controller.loadPersonalInterno(context, widget.codigoMcp!, false,
            (widget.isEditMode || widget.isViewing));
      } else {
        await controller.loadPersonalExterno(context, widget.dni!, false,
            (widget.isEditMode || widget.isViewing));
      }
    } else {
      controller.resetControllers();
      controller.dropdownController.resetAllSelections();
      controller.dropdownController.optionsMap['empresaCapacitadora']?.clear();
    }

    await controller.obtenerArchivosRegistrados(
      idOrigen: TipoActividad.CAPACITACION,
      idOrigenKey: widget.capacitacionKey,
      idTipoArchivo: OrigenArchivo.capacitacion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!widget.isEditMode && !widget.isViewing) _buildSelectorDeTipo(),
            const SizedBox(height: 20),
            Obx(() => controller.isInternoSelected.value
                ? _buildFormularioInterno()
                : _buildFormularioExterno()),
            const SizedBox(height: 20),
            _buildDatosCapacitacion(),
            const SizedBox(height: 20),
            if (widget.isEditMode || widget.isViewing) _buildArchivoSection(),
            const SizedBox(height: 20),
            if (!widget.isViewing)
              _buildBotonesAccion(widget.isEditMode)
            else
              SizedBox(),
            if (widget.isViewing) _buildRegresarButton(context) else SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorDeTipo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            controller.seleccionarInterno();
            controller.resetControllers();
          },
          child: Obx(
            () => Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: controller.isInternoSelected.value
                    ? AppTheme.backgroundBlue
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Personal Interno",
                  style: TextStyle(
                      color: controller.isInternoSelected.value
                          ? Colors.white
                          : Colors.black54),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            controller.seleccionarExterno();
            controller.resetControllers();
          },
          child: Obx(
            () => Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: controller.isInternoSelected.value
                    ? Colors.grey[200]
                    : AppTheme.backgroundBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Personal Externo",
                  style: TextStyle(
                      color: controller.isInternoSelected.value
                          ? Colors.black54
                          : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormularioInterno() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () {
              if (controller.personalPhoto.value != null) {
                try {
                  return CircleAvatar(
                    backgroundImage:
                        MemoryImage(controller.personalPhoto.value!),
                    radius: 60,
                    backgroundColor: Colors.grey,
                  );
                } catch (e) {
                  log('Error al cargar la imagen: $e');
                  return const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/user_avatar.png'),
                    radius: 60,
                    backgroundColor: Colors.grey,
                  );
                }
              } else {
                return const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user_avatar.png'),
                  radius: 60,
                  backgroundColor: Colors.grey,
                );
              }
            },
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (!isEditMode && !isViewing)
                //   SizedBox(
                //     width: 200,
                //     child: CustomTextField(
                //       label: "Código MCP 1",
                //       controller: controller.codigoMcpController,
                //       icon: const Icon(Icons.search),
                //       onIconPressed: () {
                //         controller.loadPersonalInterno(
                //             controller.codigoMcpController.text, true, isEditMode);
                //       },
                //     ),
                //   ),

                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    label: "Código MCP",
                    controller: controller.codigoMcpController,
                    icon: !(!widget.isEditMode && !widget.isViewing)
                        ? null
                        : const Icon(Icons.search),
                    readOnly: !(!widget.isEditMode && !widget.isViewing),
                    onIconPressed: () {
                      controller.loadPersonalInterno(
                          context,
                          controller.codigoMcpController.text,
                          true,
                          widget.isEditMode);
                    },
                  ),
                ),
                if (!widget.isEditMode) const SizedBox(height: 12),
                const Text('Datos del Personal',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "DNI",
                        controller: controller.dniInternoController,
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        label: "Nombres",
                        controller: controller.nombresController,
                        isReadOnly: true,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        label: "Guardia",
                        controller: controller.guardiaController,
                        isReadOnly: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioExterno() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos de la persona externa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: 200,
            child: CustomTextField(
              label: "DNI",
              controller: controller.dniExternoController,
              // icon: const Icon(Icons.search),
              icon: !(!widget.isEditMode && !widget.isViewing)
                  ? null
                  : const Icon(Icons.search),
              readOnly: !(!widget.isEditMode && !widget.isViewing),
              onIconPressed: () {
                controller.loadPersonalExterno(
                    context,
                    controller.dniExternoController.text,
                    true,
                    widget.isEditMode);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: CustomTextField(
                  label: "Nombres",
                  controller: controller.nombresController,
                  isReadOnly: true,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: CustomTextField(
                  label: "Apellido Paterno",
                  controller: controller.apellidoPaternoController,
                  isReadOnly: true,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: CustomTextField(
                  label: "Apellido Materno",
                  controller: controller.apellidoMaternoController,
                  isReadOnly: true,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDatosCapacitacion() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: widget.isViewing
                    ? CustomDropdownGlobal(
                        labelText: 'Categoría',
                        dropdownKey: 'categoria',
                        hintText: 'Selecciona categoría',
                        noDataHintText: 'No se encontraron categorías',
                        controller: controller.dropdownController,
                        isReadOnly: true,
                        isRequired: false,
                      )
                    : Obx(() => CustomDropdownGlobal(
                          labelText: 'Categoría',
                          dropdownKey: 'categoria',
                          hintText: 'Selecciona categoría',
                          noDataHintText: 'No se encontraron categorías',
                          controller: controller.dropdownController,
                          isReadOnly: !controller.isValidate.value,
                          isRequired: !widget.isViewing,
                          excludeOptions: [0],
                          onChanged: (value) {
                            controller.actualizarOpcionesEmpresaCapacitadora();
                            controller.isValidateCategoria.value = true;
                            controller.nombreEntrenadorExterno!.value = '';
                            controller.dropdownController.resetSelection(
                              'entrenador',
                            );
                            controller.dniEntrenadorController.text = '';
                          },
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: widget.isViewing
                    ? CustomDropdownGlobal(
                        labelText: 'Empresa de capacitación',
                        dropdownKey: 'empresaCapacitadora',
                        hintText: 'Selecciona empresa de capacitación',
                        noDataHintText: 'No se encontraron empresas',
                        controller: controller.dropdownController,
                        isReadOnly: true,
                        isRequired: false,
                      )
                    : Obx(() => CustomDropdownGlobal(
                          labelText: 'Empresa de capacitación',
                          dropdownKey: 'empresaCapacitadora',
                          hintText: 'Selecciona empresa de capacitación',
                          noDataHintText: 'No se encontraron empresas',
                          controller: controller.dropdownController,
                          isReadOnly: !controller.isValidateCategoria.value,
                          isRequired: !widget.isViewing,
                          onChanged: (nuevaSeleccion) {
                            if (!widget.isViewing) {
                              controller.dropdownController.selectValue(
                                'empresaCapacitadora',
                                nuevaSeleccion,
                              );
                            }
                          },
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Obx(() {
                  final categoriaSeleccionada = controller.dropdownController
                      .getSelectedValue('categoria')
                      ?.nombre;
                  if (widget.isViewing) {
                    if (categoriaSeleccionada == 'Externa') {
                      return CustomTextField(
                        label: "Entrenador",
                        controller: TextEditingController(
                            text: controller.nombreEntrenadorExterno?.value ??
                                ''),
                        isReadOnly: true,
                      );
                    } else {
                      return CustomDropdownGlobal(
                        labelText: 'Entrenador',
                        dropdownKey: 'entrenador',
                        hintText: 'Selecciona entrenador',
                        noDataHintText: 'No se encontraron entrenadores',
                        controller: controller.dropdownController,
                        isReadOnly: true,
                      );
                    }
                  }

                  if (categoriaSeleccionada == 'Externa') {
                    return Column(
                      children: [
                        CustomTextField(
                          label: "Buscar por DNI",
                          controller: controller.dniEntrenadorController,
                          icon: const Icon(Icons.search),
                          isRequired: true,
                          onIconPressed: () {
                            controller.loadEntrenadorExterno(context,
                                controller.dniEntrenadorController.text, true);
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(controller.nombreEntrenadorExterno!.value,
                            style: TextStyle(color: AppTheme.primaryColor)),
                      ],
                    );
                  } else {
                    return CustomDropdownGlobal(
                      labelText: 'Entrenador',
                      dropdownKey: 'entrenador',
                      hintText: 'Selecciona entrenador',
                      noDataHintText: 'No se encontraron entrenadores',
                      controller: controller.dropdownController,
                      isReadOnly: !controller.isValidateCategoria.value,
                      isRequired: true,
                      onChanged: (nuevaSeleccion) {
                        controller.dropdownController.selectValue(
                          'entrenador',
                          nuevaSeleccion,
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: widget.isViewing
                    ? CustomTextField(
                        label: "Fecha inicio",
                        controller: controller.fechaInicioController,
                        isReadOnly: true,
                      )
                    : Obx(() => CustomTextField(
                          label: "Fecha inicio",
                          controller: controller.fechaInicioController,
                          icon:
                              (!widget.isViewing && controller.isValidate.value)
                                  ? Icon(Icons.calendar_today)
                                  : null,
                          onIconPressed: () async {
                            controller.fechaInicio = await _selectDate(context);
                            controller.fechaInicioController.text =
                                DateFormat('dd/MM/yyyy')
                                    .format(controller.fechaInicio!);
                          },
                          isReadOnly: !controller.isValidate.value,
                          isRequired: !widget.isViewing,
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: widget.isViewing
                    ? CustomTextField(
                        label: "Fecha de término",
                        controller: controller.fechaTerminoController,
                        isReadOnly: true,
                      )
                    : Obx(() => CustomTextField(
                          label: "Fecha de término",
                          controller: controller.fechaTerminoController,
                          icon:
                              (!widget.isViewing && controller.isValidate.value)
                                  ? Icon(Icons.calendar_today)
                                  : null,
                          onIconPressed: () async {
                            controller.fechaTermino =
                                await _selectDate(context);
                            controller.fechaTerminoController.text =
                                DateFormat('dd/MM/yyyy')
                                    .format(controller.fechaTermino!);
                          },
                          isReadOnly: !controller.isValidate.value,
                          isRequired: !widget.isViewing,
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: widget.isViewing
                    ? CustomTextField(
                        label: "Horas de capacitación",
                        controller: controller.horasController,
                        isReadOnly: true,
                      )
                    : Obx(() => CustomTextField(
                          label: "Horas de capacitación",
                          controller: controller.horasController,
                          isReadOnly: !controller.isValidate.value,
                          isRequired: !widget.isViewing,
                        )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: widget.isViewing
                    ? CustomDropdownGlobal(
                        labelText: 'Capacitación',
                        dropdownKey: 'capacitacion',
                        hintText: 'Selecciona capacitación',
                        noDataHintText: 'No se encontraron capacitaciones',
                        controller: controller.dropdownController,
                        isReadOnly: true,
                        isRequired: false,
                      )
                    : Obx(() => CustomDropdownGlobal(
                          labelText: 'Capacitación',
                          dropdownKey: 'capacitacion',
                          hintText: 'Selecciona capacitación',
                          noDataHintText: 'No se encontraron capacitaciones',
                          controller: controller.dropdownController,
                          isReadOnly:
                              widget.isViewing || !controller.isValidate.value,
                          isRequired: !widget.isViewing,
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: widget.isViewing
                    ? CustomTextField(
                        label: "Nota teoría",
                        controller: controller.notaTeoriaController,
                        isReadOnly:
                            widget.isViewing || !controller.isValidate.value,
                      )
                    : Obx(() => CustomTextField(
                          label: "Nota teoría",
                          controller: controller.notaTeoriaController,
                          isReadOnly:
                              widget.isViewing || !controller.isValidate.value,
                          isRequired: false,
                        )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: widget.isViewing
                    ? CustomTextField(
                        label: "Nota práctica",
                        controller: controller.notaPracticaController,
                        isReadOnly:
                            widget.isViewing || !controller.isValidate.value,
                      )
                    : Obx(() => CustomTextField(
                          label: "Nota práctica",
                          controller: controller.notaPracticaController,
                          isReadOnly:
                              widget.isViewing || !controller.isValidate.value,
                          isRequired: false,
                        )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchivoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.attach_file, color: Colors.grey),
            SizedBox(width: 10),
            Text("Archivos adjuntos:"),
            SizedBox(width: 10),
            Text(
              "(Archivos adjuntos peso máx: 4MB c/u)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.archivosAdjuntos.isEmpty) {
            return widget.isViewing
                ? const Padding(
                    padding: EdgeInsets.only(top: 10, left: 20),
                    child: Text(
                      "No hay archivos adjuntos.",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : const SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.archivosAdjuntos.map((archivo) {
              return Container(
                width: 400,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        archivo['nombre'] ?? '',
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        archivo['nuevo'] == false
                            ? IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.blue, size: 20),
                                onPressed: () {
                                  controller.descargarArchivo(context, archivo);
                                },
                              )
                            : const SizedBox(),
                        Visibility(
                          visible: !widget.isViewing,
                          child: IconButton(
                            icon: Icon(
                              archivo['nuevo'] == true
                                  ? Icons.cancel
                                  : Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              if (archivo['nuevo'] == true) {
                                controller.removerArchivo(archivo['nombre']);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmDeleteWidget(
                                      itemName: archivo['nombre'],
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
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 10),
        if (!widget.isViewing)
          TextButton.icon(
            onPressed: () {
              controller.adjuntarDocumentos(
                context,
              );
            },
            icon: const Icon(Icons.attach_file, color: Colors.blue),
            label: const Text(
              "Adjuntar documentos",
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }

  Widget _buildRegresarButton(BuildContext context) {
    return AppButton.blue(
        text: 'Regresar',
        onPressed: () {
          controller.resetControllers();
          widget.onCancel();
        });
  }

  Widget _buildBotonesAccion(bool isEditMode) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppButton.white(
              text: 'Cancelar',
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      controller.resetControllers();
                      widget.onCancel();
                    }),
          const SizedBox(width: 20),
          AppButton.blue(
            text: isEditMode ? "Actualizar" : "Guardar",
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    bool? success = isEditMode
                        ? await controller.actualizarCapacitacion(
                            context,
                          )
                        : await controller.registrarCapacitacion(
                            context,
                          );
                    if (success!) widget.onCancel();
                  },
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return picked;
  }
}
