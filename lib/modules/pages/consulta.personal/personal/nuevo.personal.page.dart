import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import '../consulta.personal.controller.dart';
import 'nuevo.personal.controller.dart';
import 'package:intl/intl.dart';

class NuevoPersonalPage extends StatefulWidget {
  final bool isEditing;
  final bool isViewing;
  final Personal personal;
  final VoidCallback onCancel;

  NuevoPersonalPage({
    required this.isEditing,
    required this.isViewing,
    required this.personal,
    required this.onCancel,
    super.key,
  });

  @override
  State<NuevoPersonalPage> createState() => _NuevoPersonalPageState();
}

class _NuevoPersonalPageState extends State<NuevoPersonalPage> {
  @override
  void initState() {
    super.initState();
    consultPersonalController = PersonalSearchController(
      context,
    );
    _initializePersonalData();
  }

  final NuevoPersonalController controller = NuevoPersonalController();

  late final PersonalSearchController consultPersonalController;

  final PersonalSearchController controllerPersonalSearch = Get.find();

  void _initializePersonalData() {
    if (widget.isEditing || widget.isViewing) {
      controller.loadPersonalPhoto(widget.personal.inPersonalOrigen!);
      controller.personalData = widget.personal;
      controller.dniController.text = widget.personal.numeroDocumento!;
      controller.nombresController.text =
          '${widget.personal.primerNombre} ${widget.personal.segundoNombre}';
      controller.puestoTrabajoController.text = widget.personal.cargo!.nombre!;
      controller.codigoController.text = widget.personal.codigoMcp!;
      controller.apellidoPaternoController.text =
          widget.personal.apellidoPaterno!;
      controller.apellidoMaternoController.text =
          widget.personal.apellidoMaterno!;
      controller.gerenciaController.text = widget.personal.gerencia!;
      controller.fechaIngreso = widget.personal.fechaIngreso;
      controller.fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(controller.fechaIngreso!);
      controller.areaController.text = widget.personal.area!;
      //controller.categoriaLicenciaController.text = personal.licenciaCategoria!;

      if (widget.personal.licenciaCategoria!.key != 0) {
        controller.dropdownController.selectValueKey(
            'categoriaLicencia', widget.personal.licenciaCategoria!.key);
      } else {
        controller.dropdownController.selectValueKey('categoriaLicencia', null);
      }
      controller.codigoLicenciaController.text =
          widget.personal.licenciaConducir!;
      if (widget.personal.guardia!.key != 0) {
        controller.dropdownController
            .selectValueKey('guardiaRegistro', widget.personal.guardia!.key);
      } else {
        controller.dropdownController.selectValueKey('guardiaRegistro', null);
      }
      controller.restriccionesController.text = widget.personal.restricciones!;
      controller.fechaIngresoMina = widget.personal.fechaIngresoMina;
      controller.fechaIngresoMinaController.text =
          DateFormat('dd/MM/yyyy').format(controller.fechaIngresoMina!);

      controller.fechaRevalidacion = widget.personal.fechaRevalidacion;
      controller.fechaRevalidacionController.text =
          controller.fechaRevalidacion != null
              ? DateFormat('dd/MM/yyyy').format(controller.fechaRevalidacion!)
              : ' ';
      controller.isOperacionMina.value = widget.personal.operacionMina == 'S';
      controller.isZonaPlataforma.value = widget.personal.zonaPlataforma == 'S';
      controller.estadoPersonalKey.value = widget.personal.estado!.key!;
      controller.estadoPersonalNombre.value = widget.personal.estado!.nombre!;
      controller.obtenerArchivosRegistrados(widget.personal.key!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(
              context,
            ),
            const SizedBox(height: 30),
            _buildDatosAdicionalesSection(context),
            const SizedBox(height: 30),
            if (widget.isViewing) _buildRegresarButton(context),
            if (!widget.isViewing)
              _buildButtons(context, consultPersonalController),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Obx(() {
                if (controller.personalPhoto.value != null &&
                    controller.personalPhoto.value!.isNotEmpty) {
                  try {
                    return CircleAvatar(
                      backgroundImage:
                          MemoryImage(controller.personalPhoto.value!),
                      radius: 95,
                      backgroundColor: Colors.grey,
                    );
                  } catch (e) {
                    log('Error al cargar la imagen: $e');
                    return const CircleAvatar(
                      backgroundImage:
                          AssetImage('assets/images/user_avatar.png'),
                      radius: 95,
                      backgroundColor: Colors.grey,
                    );
                  }
                } else {
                  return const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/user_avatar.png'),
                    radius: 95,
                    backgroundColor: Colors.grey,
                  );
                }
              }),
              const SizedBox(height: 10),
              Row(
                children: [
                  Obx(
                    () {
                      int estado = controller.estadoPersonalKey.value;
                      Color estadoColor;
                      switch (estado) {
                        case 95:
                          estadoColor = Colors.green;
                          break;
                        case 96:
                          estadoColor = Colors.red;
                          break;
                        default:
                          estadoColor = Colors.grey;
                          break;
                      }
                      return Icon(Icons.circle, color: estadoColor, size: 12);
                    },
                  ),
                  const SizedBox(width: 10),
                  Obx(
                    () => Text(
                      controller.estadoPersonalNombre.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
              child: _buildPersonalDataFields(
            context,
          ))
        ],
      ),
    );
  }

  Widget _buildPersonalDataFields(
    BuildContext context,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: "DNI",
                    controller: controller.dniController,
                    icon: Obx(() {
                      return controller.isLoadingDni.value
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.search);
                    }),
                    isReadOnly: widget.isEditing || widget.isViewing,
                    onIconPressed: () {
                      if (!controller.isLoadingDni.value &&
                          !widget.isEditing &&
                          !widget.isViewing) {
                        _searchPersonalByDNI(
                          context,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    label: "Nombres",
                    controller: controller.nombresController,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    label: "Puesto de Trabajo",
                    controller: controller.puestoTrabajoController,
                    isReadOnly: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(child: _buildSecondColumn()),
            const SizedBox(width: 20),
            Expanded(child: _buildThirdColumn()),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Código",
          controller: controller.codigoController,
          isReadOnly: true,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Apellido Paterno",
          controller: controller.apellidoPaternoController,
          //isReadOnly: isViewing,
          isReadOnly: true,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Gerencia",
          controller: controller.gerenciaController,
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildThirdColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: "Fecha Ingreso",
          controller: controller.fechaIngresoController,
          isReadOnly: true,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Apellido Materno",
          controller: controller.apellidoMaternoController,
          //isReadOnly: isViewing,
          isReadOnly: true,
        ),
        const SizedBox(height: 15),
        CustomTextField(
          label: "Área",
          controller: controller.areaController,
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildDatosAdicionalesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Datos adicionales",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: CustomDropdownGlobal(
                  labelText: "Categoria de licencia",
                  dropdownKey: 'categoriaLicencia',
                  hintText: 'Selecciona categoria de licencia',
                  noDataHintText: 'No se encontraron categorias de licencia',
                  controller: controller.dropdownController,
                  isReadOnly: widget.isViewing,
                  isRequired: !widget.isViewing,
                ),
                /*
                child: CustomTextField(
                  label: "Categoria Licencia",
                  controller: controller.categoriaLicenciaController,
                  isReadOnly: true,
                  isRequired: false,
                ),
                */
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  label: "Código Licencia",
                  controller: controller.codigoLicenciaController,
                  isReadOnly: widget.isViewing,
                  isRequired: !widget.isViewing,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  label: "Fecha Ingreso a Mina",
                  controller: controller.fechaIngresoMinaController,
                  icon: const Icon(Icons.calendar_today),
                  isReadOnly: widget.isViewing,
                  isRequired: !widget.isViewing,
                  onIconPressed: () async {
                    if (!widget.isViewing) {
                      controller.fechaIngresoMina = await _selectDate(context);
                      if (controller.fechaIngresoMina != null) {
                        controller.fechaIngresoMinaController.text =
                            DateFormat('dd/MM/yyyy')
                                .format(controller.fechaIngresoMina!);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  label: "Fecha de Revalidación",
                  controller: controller.fechaRevalidacionController,
                  icon: const Icon(Icons.calendar_today),
                  isReadOnly: widget.isViewing,
                  isRequired: !widget.isViewing,
                  onIconPressed: () async {
                    if (!widget.isViewing) {
                      controller.fechaRevalidacion = await _selectDate(context);
                      controller.fechaRevalidacionController.text =
                          DateFormat('dd/MM/yyyy')
                              .format(controller.fechaRevalidacion!);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: CustomDropdownGlobal(
                  labelText: "Guardia",
                  dropdownKey: 'guardiaRegistro',
                  hintText: 'Selecciona guardia',
                  noDataHintText: 'No se encontraron guardias',
                  controller: controller.dropdownController,
                  isReadOnly: widget.isViewing ? true : false,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text("Autorizado para operar en:"),
              ),
              Expanded(
                child: Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.isOperacionMina.value,
                          onChanged: widget.isViewing
                              ? null
                              : (value) {
                                  controller.isOperacionMina.value =
                                      value ?? false;
                                },
                        )),
                    const Text("Operaciones mina"),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Obx(() => Checkbox(
                          value: controller.isZonaPlataforma.value,
                          onChanged: widget.isViewing
                              ? null
                              : (value) {
                                  controller.isZonaPlataforma.value =
                                      value ?? false;
                                },
                        )),
                    const Text("Zonas o plataforma"),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Restricciones"),
          CustomTextField(
            label: "",
            controller: controller.restriccionesController,
            isReadOnly: widget.isViewing,
          ),
          const SizedBox(height: 20),
          _buildArchivoSection(
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildArchivoSection(
    BuildContext context,
  ) {
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
                    if (!widget.isViewing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          archivo['nuevo'] == false
                              ? IconButton(
                                  icon: const Icon(Icons.download,
                                      color: Colors.blue, size: 20),
                                  onPressed: () {
                                    controller.descargarArchivo(
                                        context, archivo);
                                  },
                                )
                              : const SizedBox(),
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
              controller.adjuntarDocumentos();
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

  // Botón para regresar cuando se está visualizando
  Widget _buildRegresarButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          controller.resetControllers();
          consultPersonalController.resetControllers();
          await consultPersonalController.searchPersonal();
          widget.onCancel();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text("Regresar", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Botones para editar o cancelar
  Widget _buildButtons(BuildContext context,
      PersonalSearchController consultaPersonalController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () async {
            controller.resetControllers();
            consultPersonalController.resetControllers();
            await consultPersonalController.searchPersonal();
            widget.onCancel();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
        ),
        SizedBox(
          width: 30,
        ),
        ElevatedButton(
          onPressed: controller.isSaving.value
              ? null
              : () async {
                  bool success = false;
                  String accion = widget.isEditing ? 'actualizar' : 'registrar';

                  success = await controller.gestionarPersona(
                    accion: accion,
                    context: context,
                  );
                  if (success) {
                    consultPersonalController.resetControllers();
                    await consultPersonalController.searchPersonal();
                    widget.onCancel();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: Obx(() {
            return controller.isSaving.value
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    "Guardar",
                    style: TextStyle(color: Colors.white),
                  );
          }),
        ),
      ],
    );
  }

  void _searchPersonalByDNI(
    BuildContext context,
  ) async {
    if (!widget.isEditing && !widget.isViewing) {
      await controller.buscarPersonalPorDni(
          context, controller.dniController.text);
    }
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
