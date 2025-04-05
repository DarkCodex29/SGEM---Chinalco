import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.controller.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.page.controller.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';

class InfoPersonMonitoringWidegt extends StatefulWidget {
  const InfoPersonMonitoringWidegt(
      {super.key,
      required this.isSmallScreen,
      required this.createMonitoringController,
      required this.monitoringSearchController,
      this.isEditing = false});
  final bool isSmallScreen;
  final CreateMonitoringController createMonitoringController;
  final MonitoringSearchController monitoringSearchController;
  final bool isEditing;

  @override
  State<InfoPersonMonitoringWidegt> createState() =>
      _InfoPersonMonitoringWidegtState();
}

class _InfoPersonMonitoringWidegtState
    extends State<InfoPersonMonitoringWidegt> {
  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      widget.monitoringSearchController.formWithUserValid.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.isSmallScreen
            ? Column(
                children: [
                  getImage(),
                  const SizedBox(width: 5),
                  const Text(
                    "Datos del Personal",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.backgroundBlue,
                        fontSize: 18),
                  ),
                  const SizedBox(width: 5),
                  CustomTextField(
                    label: "Código MCP",
                    isReadOnly: true,
                    controller:
                        widget.createMonitoringController.codigoMCP2Controller,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Nombres y Apellidos",
                    isReadOnly: true,
                    controller:
                        widget.createMonitoringController.fullNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Guardia",
                    isReadOnly: true,
                    controller:
                        widget.createMonitoringController.guardController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Estado del  entrenamiento",
                    isReadOnly: true,
                    controller: widget
                        .createMonitoringController.stateTrainingController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: "Módulo",
                    isReadOnly: true,
                    controller:
                        widget.createMonitoringController.moduleController,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isEditing)
                    SizedBox(
                      width: 400,
                      child: CustomTextField(
                        label: "Código MCP Nuevo",
                        controller: widget
                            .createMonitoringController.codigoMCPController,
                        icon: Obx(() {
                          return widget.createMonitoringController
                                  .isLoadingCodeMcp.value
                              ? CupertinoActivityIndicator(
                                  radius: 10,
                                  color: Colors.grey,
                                )
                              : Icon(Icons.search);
                        }),
                        readOnly: widget.isEditing,
                        onIconPressed: () async {
                          if (!widget.createMonitoringController
                              .isLoadingCodeMcp.value) {
                            await widget.createMonitoringController
                                .searchPersonByCodeMcp(
                              context,
                            );

                            if (widget.createMonitoringController
                                        .selectedPersonKey.value !=
                                    null &&
                                widget.createMonitoringController
                                    .codigoMCPController.text.isNotEmpty) {
                              final resultado = await widget
                                  .monitoringSearchController
                                  .listarEstadoEntrenamiento(
                                      context,
                                      widget.createMonitoringController
                                          .codigoMCPController.text);

                              if (resultado) {
                                widget.monitoringSearchController
                                    .formWithUserValid.value = true;
                              } else {
                                widget.createMonitoringController
                                    .resetInfoPerson();
                                widget.createMonitoringController.clearModel();
                              }
                            } else {
                              //TODO: bloquear todos los controles
                              widget.monitoringSearchController
                                  .formWithUserValid.value = false;
                            }

                            // setState(() {});
                          }
                        },
                      ),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Row(
                        children: [
                          getImage(),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Datos del Personal",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.backgroundBlue,
                                    fontSize: 19),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: CustomTextField(
                                      label: "Nombres y Apellidos",
                                      isReadOnly: true,
                                      controller: widget
                                          .createMonitoringController
                                          .fullNameController,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: CustomTextField(
                                      label: "Guardia",
                                      isReadOnly: true,
                                      controller: widget
                                          .createMonitoringController
                                          .guardController,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    flex: 2,
                                    child: CustomTextField(
                                      label: "Estado del  entrenamiento",
                                      isReadOnly: true,
                                      controller: widget
                                          .createMonitoringController
                                          .stateTrainingController,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    flex: 2,
                                    child: CustomTextField(
                                      label: "Módulo",
                                      isReadOnly: true,
                                      controller: widget
                                          .createMonitoringController
                                          .moduleController,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget getImage() {
    return Obx(() {
      if (widget.createMonitoringController.personalPhoto.value == null) {
        return const CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: AssetImage('assets/images/user_avatar.png'),
          radius: 40,
        );
      }
      return CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage:
            MemoryImage(widget.createMonitoringController.personalPhoto.value!),
        radius: 40,
      );
    });
  }
}
