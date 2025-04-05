import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.controller.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.page.controller.dart';
import 'package:sgem/modules/pages/monitoring/widget/guardia.disponible.dart';
import 'package:sgem/shared/models/fecha.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/personal.dart';
import 'package:sgem/shared/widgets/custom.text.fromfield.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class FormMonitoringWidget extends StatefulWidget {
  const FormMonitoringWidget(
      {super.key,
      required this.isSmallScreen,
      required this.monitoringSearchController,
      required this.createMonitoringController,
      required this.isEditing,
      this.isView = false});
  final bool isSmallScreen;
  final MonitoringSearchController monitoringSearchController;
  final CreateMonitoringController createMonitoringController;
  final bool isEditing;
  final bool isView;

  @override
  State<FormMonitoringWidget> createState() => _FormMonitoringWidgetState();
}

class _FormMonitoringWidgetState extends State<FormMonitoringWidget> {
  @override
  void initState() {
    super.initState();

    metodosInit();
  }

  metodosInit() async {
    if (!widget.isEditing && !widget.isView) {
      widget.monitoringSearchController.limpiarListasRegistroEdicion();
      widget.monitoringSearchController.limpiarListasEquiposRegistroEdicion();

      widget.monitoringSearchController.formWithUserValid.value = false;
    } else {
      if (widget.isEditing) {
        widget.monitoringSearchController.formWithUserValid.value = true;
      }

      if (widget.isView) {
        widget.monitoringSearchController.formWithUserValid.value = false;
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                children: [
                  if (widget.isSmallScreen)
                    Column(
                      children: [
                        _buildDropdownEstadoEntrenamiento(),
                        const SizedBox(height: 10),
                        _buildDropdownEquipo(),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          label: "Horas",
                          controller:
                              widget.createMonitoringController.horasController,
                          maxLength: 2,
                          isReadOnly: widget.isView,
                        ),
                        const SizedBox(height: 10),
                        _buildDropdownEntrenadorResponsable(),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          label: "Fecha real de monitoreo",
                          isReadOnly: true,
                          controller: TextEditingController(
                            text: widget.createMonitoringController
                                        .fechaRealMonitoreoController ==
                                    null
                                ? ""
                                : DateFormat('dd/MM/yyyy').format(
                                    widget.createMonitoringController
                                        .fechaRealMonitoreoController!,
                                  ),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          onIconPressed: () async {
                            if (widget.isView) {
                              return;
                            }
                            final date = await _chooseDate(context);
                            widget.createMonitoringController
                                .fechaRealMonitoreoController = date;
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          isRequired: false,
                          label: "Fecha Aproximada de monitoreo",
                          isReadOnly: true,
                          controller: TextEditingController(
                            text: widget.createMonitoringController
                                        .fechaProximoMonitoreoController ==
                                    null
                                ? ""
                                : DateFormat('dd/MM/yyyy').format(
                                    widget.createMonitoringController
                                        .fechaProximoMonitoreoController!,
                                  ),
                          ),
                          icon: const Icon(Icons.calendar_month),
                          onIconPressed: () async {
                            if (widget.isView) {
                              return;
                            }
                            final date = await _chooseDate(context);
                            widget.createMonitoringController
                                .fechaProximoMonitoreoController = date;
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDropdownCondition(),
                        const SizedBox(height: 10),
                        CustomTextFormField(
                          label: "Comentarios",
                          controller: widget
                              .createMonitoringController.commentController,
                          maxLines: 3,
                          maxLength: 200,
                          isReadOnly: widget.isView,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownEstadoEntrenamiento(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildDropdownEquipo(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildHorasMonitoreo(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownEntrenadorResponsable(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFechaRealMonitoreo(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildFechaAproximadaMonitoreo(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownCondition(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildComentariosMonitoreo(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.isEditing || widget.isView)
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Adjuntar archivo:'),
                    SizedBox(width: 10),
                    Text(
                      "(Archivos adjuntos peso máx: 4MB c/u)",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                _buildArchivoSection("Monitoreo de equipos pesados:"),
                _buildArchivoOtrosSection("Otros:"),
              ],
            ),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
            child: _buildButtons(context),
          )
        ],
      ),
    );
  }

  Widget _buildHorasMonitoreo() {
    return Obx(() {
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      return CustomTextFormField(
        label: "Horas",
        controller: widget.createMonitoringController.horasController,
        maxLength: 2,
        isReadOnly: !formStatus, //widget.isView,
      );
    });
  }

  Widget _buildFechaRealMonitoreo() {
    return Obx(() {
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      return CustomTextFormField(
        label: "Fecha real de monitoreo",
        isReadOnly: true,
        controller: TextEditingController(
          text:
              widget.createMonitoringController.fechaRealMonitoreoController ==
                      null
                  ? ""
                  : DateFormat('dd/MM/yyyy').format(
                      widget.createMonitoringController
                          .fechaRealMonitoreoController!,
                    ),
        ),
        icon: const Icon(Icons.calendar_month),
        onIconPressed: !formStatus
            ? null
            : () async {
                if (widget.isView) {
                  return;
                }
                final date = await _chooseDate(context);
                widget.createMonitoringController.fechaRealMonitoreoController =
                    date;
                setState(() {});
              },
      );
    });
  }

  Widget _buildFechaAproximadaMonitoreo() {
    return Obx(() {
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      return Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              isRequired: false,
              label: "Fecha próxima de monitoreo",
              isReadOnly: true,
              controller: TextEditingController(
                text: widget.createMonitoringController
                            .fechaProximoMonitoreoController ==
                        null
                    ? ""
                    : DateFormat('dd/MM/yyyy').format(
                        widget.createMonitoringController
                            .fechaProximoMonitoreoController!,
                      ),
              ),
              icon: const Icon(Icons.calendar_month),
              onIconPressed: !formStatus
                  ? null
                  : () async {
                      if (widget.isView) {
                        return;
                      }
                      final date = await _chooseDate(context);
                      widget.createMonitoringController
                          .fechaProximoMonitoreoController = date;
                      setState(() {});
                    },
            ),
          ),
          IconButton(
              onPressed: !formStatus
                  ? null
                  : () async {
                      if (widget.createMonitoringController.fechas.length ==
                          0) {
                        widget.createMonitoringController
                            .mostrarErroresValidacion(context, [
                          'El guardia ${widget.createMonitoringController.guardController.text}, no cuenta con fechas disponibles'
                        ]);
                      } else {
                        _mostrarGuardiasDisponibles();
                      }
                    },
              tooltip: 'Mostrar guardias disponibles',
              icon: Icon(
                Icons.info_outline_rounded,
                color: Colors.grey,
              ))
        ],
      );
    });
  }

  Widget _buildComentariosMonitoreo() {
    return Obx(() {
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;
      return CustomTextFormField(
        label: "Comentarios",
        controller: widget.createMonitoringController.commentController,
        maxLines: 3,
        maxLength: 200,
        isReadOnly: !formStatus, //widget.isView,
      );
    });
  }

  Widget _buildArchivoSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Obx(() {
          return Row(
            children: [
              const SizedBox(height: 20),
              SizedBox(width: 250, child: Text(title)),
              const SizedBox(height: 20),
              !widget.isView
                  ? IconButton(
                      onPressed: () =>
                          widget.createMonitoringController.adjuntarDocumentos(
                        context,
                      ),
                      icon: const Icon(Icons.attach_file, color: Colors.blue),
                    )
                  : Container(),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.createMonitoringController.archivosAdjuntos
                    .map((archivo) {
                  return Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          // if (widget.isEditing || widget.isView) {
                          //   return;
                          // }
                          if (widget.isView) {
                            return;
                          }

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: ConfirmDeleteWidget(
                                    itemName: '',
                                    entityType: 'archivo ${archivo['nombre']}',
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: () async {
                                      // confirmarEliminar = true;
                                      await widget.createMonitoringController
                                          .eliminarArchivo(archivo['nombre'],
                                              archivo['key']);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: Text(
                          archivo['nombre'] ?? '',
                          style: TextStyle(
                            color: archivo['nuevo'] == true
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () {
                          widget.createMonitoringController
                              .descargarArchivo(context, archivo);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
          // return Row(
          //   children: [
          //     const SizedBox(height: 20),
          //     SizedBox(width: 200, child: Text(title)),
          //     const SizedBox(height: 20),
          //     !widget.isView
          //         ? IconButton(
          //             onPressed: () => widget.createMonitoringController
          //                 .adjuntarDocumentos(),
          //             icon: const Icon(Icons.attach_file, color: Colors.blue),
          //           )
          //         : Container(),
          //     const SizedBox(height: 10),
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: widget.createMonitoringController.archivosAdjuntos
          //           .map((archivo) {
          //         return Row(
          //           children: [
          //             const SizedBox(height: 20),
          //             Text(title),
          //             const SizedBox(height: 20),
          //             !widget.isView
          //                 ? IconButton(
          //                     onPressed: () => widget.createMonitoringController
          //                         .adjuntarDocumentos(),
          //                     icon: const Icon(Icons.attach_file,
          //                         color: Colors.blue),
          //                   )
          //                 : Container(),
          //             const SizedBox(height: 10),
          //             TextButton.icon(
          //               onPressed: () {
          //                 // if (widget.isEditing || widget.isView) {
          //                 //   return;
          //                 // }
          //                 if (widget.isView) {
          //                   return;
          //                 }
          //                 widget.createMonitoringController
          //                     .eliminarArchivo(archivo['nombre']);
          //               },
          //               icon: const Icon(Icons.close, color: Colors.red),
          //               label: Text(
          //                 archivo['nombre'] ?? '',
          //                 style: TextStyle(
          //                   color: archivo['nuevo'] == true
          //                       ? Colors.red
          //                       : Colors.green,
          //                 ),
          //               ),
          //             ),
          //             IconButton(
          //               icon: const Icon(Icons.download, color: Colors.blue),
          //               onPressed: () {
          //                 widget.createMonitoringController
          //                     .descargarArchivo(archivo);
          //               },
          //             ),
          //           ],
          //         );
          //       }).toList(),
          //     ),
          //   ],
          // );
        }),
        // if (!widget.isView) const SizedBox(height: 10),
        // if (!widget.isView)
        //   TextButton.icon(
        //     onPressed: () {
        //       widget.createMonitoringController.adjuntarDocumentos();
        //     },
        //     icon: const Icon(Icons.attach_file, color: Colors.blue),
        //     label: const Text("Adjuntar Documentos",
        //         style: TextStyle(color: Colors.blue)),
        //   ),
      ],
    );
  }

  Widget _buildArchivoOtrosSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Obx(() {
          return Row(
            children: [
              const SizedBox(height: 20),
              SizedBox(width: 250, child: Text(title)),
              const SizedBox(height: 20),
              !widget.isView
                  ? IconButton(
                      onPressed: () => widget.createMonitoringController
                          .adjuntarDocumentosOtros(
                        context,
                      ),
                      icon: const Icon(Icons.attach_file, color: Colors.blue),
                    )
                  : Container(),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget
                    .createMonitoringController.archivosAdjuntosOtros
                    .map((archivo) {
                  return Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          // if (widget.isEditing || widget.isView) {
                          //   return;
                          // }
                          if (widget.isView) {
                            return;
                          }

                          await showDialog(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: ConfirmDeleteWidget(
                                    itemName: '',
                                    entityType: 'archivo ${archivo['nombre']}',
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: () async {
                                      await widget.createMonitoringController
                                          .eliminarArchivoOtros(
                                              archivo['nombre'],
                                              archivo['key']);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: Text(
                          archivo['nombre'] ?? '',
                          style: TextStyle(
                            color: archivo['nuevo'] == true
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () {
                          widget.createMonitoringController
                              .descargarArchivo(context, archivo);
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          );
        }),
        // if (!widget.isView) const SizedBox(height: 10),
        // if (!widget.isView)
        //   TextButton.icon(
        //     onPressed: () {
        //       widget.createMonitoringController.adjuntarDocumentosOtros();
        //     },
        //     icon: const Icon(Icons.attach_file, color: Colors.blue),
        //     label: const Text("Adjuntar Documentos",
        //         style: TextStyle(color: Colors.blue)),
        //   ),
      ],
    );
  }

  Widget _buildDropdownEstadoEntrenamiento() {
    return Obx(() {
      if (widget.createMonitoringController.isLoandingDetail.value) {
        return const CupertinoActivityIndicator(
          radius: 10,
          color: Colors.grey,
        );
      }

      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      List<MaestroDetalle> tmpList = List.from(
          widget.monitoringSearchController.estadoEntrenamientoOpcionesForm);

      var options =
          tmpList.map((option) => (option.key!, option.value)).toList();

      var initialValue = widget
          .createMonitoringController.selectedEstadoEntrenamientoKey.value;

      print('Crear mopnitor:: opciones : ${options.length} ${formStatus}');
      Logger('FormMonitoringWidget')
        ..info('Estado: $options')
        ..info(initialValue);

      // if (options.isEmpty ||
      //     options.any((element) => element.$1 == initialValue)) {
      //   return const CircularProgressIndicator();
      // }

      // return const CircularProgressIndicator();

      return SimpleAppDropdown(
        label: 'Estado del entrenamiento',
        hint: 'Selecciona Estado de Entrenamiento',
        options: options,
        readOnly: !formStatus,
        isRequired: true,
        initialValue: initialValue,
        onChanged: (value) async {
          final selectedOption = options.firstWhere(
            (option) => option.$1 == value,
          );
          widget.createMonitoringController.selectedEstadoEntrenamientoKey
              .value = selectedOption.$1;

          widget.createMonitoringController.selectedEquipoKey.value = null;
          await widget.monitoringSearchController
              .listarEquipoEntrenamiento(selectedOption.$1);
        },
      );
    });
  }

  Widget _buildDropdownCondition() {
    return Obx(() {
      if (widget.monitoringSearchController.condicionOpciones.isEmpty) {
        return const CupertinoActivityIndicator(
          radius: 10,
          color: Colors.grey,
        );
      }
      if (widget.createMonitoringController.isLoandingDetail.value) {
        return const CupertinoActivityIndicator(
          radius: 10,
          color: Colors.grey,
        );
      }
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      List<MaestroDetalle> options =
          widget.monitoringSearchController.condicionOpciones;
      return CustomDropdown(
        hintText: 'Selecciona condicion',
        labelName: "Condición",
        isReadOnly: !formStatus!, // widget.isView,
        options: options.map((option) => option.valor!).toList(),
        selectedValue:
            widget.createMonitoringController.selectedCondicionKey.value != null
                ? options
                    .firstWhere((option) =>
                        option.key ==
                        widget.createMonitoringController.selectedCondicionKey
                            .value)
                    .valor
                : null,
        isSearchable: false,
        isRequired: true,
        onChanged: (value) {
          final selectedOption = options.firstWhere(
            (option) => option.valor == value,
          );
          widget.createMonitoringController.selectedCondicionKey.value =
              selectedOption.key;
        },
      );
    });
  }

  Widget _buildDropdownEquipo() {
    return Obx(() {
      // if (widget.monitoringSearchController.equipoOpciones.isEmpty) {
      //   return const CupertinoActivityIndicator(
      //     radius: 10,
      //     color: Colors.grey,
      //   );
      // }
      if (widget.createMonitoringController.isLoandingDetail.value) {
        return const CupertinoActivityIndicator(
          radius: 10,
          color: Colors.grey,
        );
      }

      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;

      List<MaestroDetalle> tmpList =
          List.from(widget.monitoringSearchController.equipoOpcionesForm);

      var options =
          tmpList.map((option) => (option.key!, option.value)).toList();

      options = options.toSet().toList();

      final initialValue =
          widget.createMonitoringController.selectedEquipoKey.value;

      Logger('FormMonitoringWidget')
        ..info('Equipo: $options')
        ..info(initialValue);

      // if (options.isEmpty ||
      //     options.any((element) => element.$1 == initialValue)) {
      //   return const CircularProgressIndicator();
      // }

      return SimpleAppDropdown(
        label: 'Equipo',
        hint: 'Selecciona Equipo',
        options: options,
        readOnly: !formStatus,
        isRequired: true,
        initialValue: widget.createMonitoringController.selectedEquipoKey.value,
        onChanged: (value) async {
          if (options.length > 0) {
            final selectedOption = options.firstWhere(
              (option) => option.$1 == value,
            );

            widget.createMonitoringController.selectedEquipoKey.value =
                selectedOption.$1;
          }
        },
      );
    });
  }

  Widget _buildDropdownEntrenadorResponsable() {
    return Obx(() {
      // if (widget.monitoringSearchController.equipoOpciones.isEmpty) {
      //   return const CupertinoActivityIndicator(
      //     radius: 10,
      //     color: Colors.grey,
      //   );
      // }
      final formStatus =
          widget.monitoringSearchController.formWithUserValid.value ?? false;
      if (widget.createMonitoringController.isLoandingDetail.value) {
        return const CupertinoActivityIndicator(
          radius: 10,
          color: Colors.grey,
        );
      }
      List<Personal> options = widget.monitoringSearchController.entrenadores;
      return CustomDropdown(
        hintText: 'Selecciona Entrenador',
        labelName: "Entrenador",
        isReadOnly: !formStatus!, // widget.isView,
        options: options.map((option) => option.nombreCompleto!).toList(),
        selectedValue:
            widget.createMonitoringController.selectedEntrenadorKey.value !=
                    null
                ? options
                    .firstWhere((option) =>
                        option.inPersonalOrigen ==
                        widget.createMonitoringController.selectedEntrenadorKey
                            .value)
                    .nombreCompleto
                    .toString()
                : null,
        isSearchable: false,
        isRequired: true,
        onChanged: (value) {
          final selectedOption = options.firstWhere(
            (option) => option.nombreCompleto == value,
          );
          widget.createMonitoringController.selectedEntrenadorKey.value =
              selectedOption.inPersonalOrigen;
        },
      );
    });
  }

  Future<DateTime?> _chooseDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime oneYearFromToday = DateTime(
        DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);

    final DateTime now = DateTime.now();

    var initialDate = now;

    initialDate = initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now;

    final result = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorSchemeSeed: AppTheme.backgroundBlue,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: today, //.subtract(const Duration(days: 30)), //initialDate,
      firstDate: DateTime(1900),
      lastDate: oneYearFromToday,
      // lastDate: DateTime(2025),
    );

    if (result == null) {
      return null;
    }
    return result;
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () {
            widget.monitoringSearchController.screen.value =
                MonitoringSearchScreen.none;

            widget.monitoringSearchController
                .searchMonitoring(pageNumber: 1, pageSize: 10);
            widget.createMonitoringController.clearModel();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: Text(widget.isView ? 'Regresar' : "Cancelar",
              style: TextStyle(color: Colors.grey)),
        ),
        if (!widget.isView)
          ElevatedButton(
            onPressed: widget.createMonitoringController.isSaving.value
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    final state = await widget.createMonitoringController
                        .saveMonitoring(context);

                    if (state) {
                      widget.monitoringSearchController.searchMonitoring();

                      if (widget.isEditing) {
                        await widget.createMonitoringController.uploadArchive();
                        await widget.createMonitoringController
                            .uploadArchiveOtros();

                        widget.monitoringSearchController.screen.value =
                            MonitoringSearchScreen.none;
                      } else {
                        widget.monitoringSearchController.screen.value =
                            MonitoringSearchScreen.none;
                        // widget.monitoringSearchController.screen.value =
                        //     widget.monitoringSearchController.clearFilter();
                        widget.createMonitoringController.clearModel();
                        widget.monitoringSearchController
                            .searchMonitoring(pageNumber: 1, pageSize: 10);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: Obx(() {
              return widget.createMonitoringController.isSaving.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text("Guardar",
                      style: TextStyle(color: Colors.white));
            }),
          ),
      ],
    );
  }

  void _mostrarGuardiasDisponibles() async {
    //widget.createMonitoringController.guardController.value
    showDialog(
      context: context,
      //barrierColor: Colors.white,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            width: 350,
            // height:  MediaQuery.of(context).size.height * 0.5,
            padding: EdgeInsets.all(16.0),
            child: Obx(() {
              List<Fecha> fechas =
                  List.from(widget.createMonitoringController.fechas);
              return GuardiaDisponibleModal(
                guardia: widget.createMonitoringController.guardController.text,
                fechas: fechas,
              );
            }),
          ),
        );
      },
    );
  }
}
