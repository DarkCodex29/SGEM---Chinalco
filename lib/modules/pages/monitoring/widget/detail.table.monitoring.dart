import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.controller.dart';
import 'package:sgem/modules/pages/monitoring/controllers/monitoring.page.controller.dart';
import 'package:sgem/shared/widgets/app_visibility.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.motivo.dart';
import 'package:sgem/shared/widgets/table/custom.table.text.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';

class DetailTableMonitoring extends StatelessWidget {
  const DetailTableMonitoring(
      {super.key, required this.controller, required this.isSmallScreen});
  final MonitoringSearchController controller;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final CreateMonitoringController createMonitoringController =
        Get.put(CreateMonitoringController());
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 550,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            actionsWidgets(createMonitoringController),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable2(
                  showBottomBorder: true,
                  columnSpacing: 20.0,
                  minWidth: 2190.0,
                  dataRowHeight: 52.0,
                  headingRowHeight: 44.0,
                  fixedColumnsColor: Colors.red,
                  headingRowColor:
                      MaterialStatePropertyAll(Colors.grey.shade200),
                  columns: const [
                    DataColumn2(
                      fixedWidth: 140,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Código MCP",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Apellido Paterno",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Apellido Materno",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Nombres",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Guardia",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Equipo",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 220,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Entrenador Responsable",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 220,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Condición de monitoreo",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 170,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Fecha del monitoreo",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 140,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Estado  del registro",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                    DataColumn2(
                      fixedWidth: 240,
                      size: ColumnSize.L,
                      label: CustomText(
                          title: "Acciones",
                          fontWeight: FontWeight.bold,
                          textColor: Color.fromARGB(190, 0, 0, 0)),
                    ),
                  ],
                  rows: List.generate(
                    controller.monitoringAll.length,
                    (index) {
                      return DataRow(
                        color: MaterialStatePropertyAll(Colors.white),
                        cells: [
                          DataCell(CustomText(
                            title: controller.monitoringAll[index].codigoMcp,
                          )),
                          DataCell(CustomText(
                            title:
                                controller.monitoringAll[index].apellidoPaterno,
                          )),
                          DataCell(CustomText(
                            title:
                                controller.monitoringAll[index].apellidoMaterno,
                          )),
                          DataCell(CustomText(
                            title:
                                "${controller.monitoringAll[index].primerNombre} ${controller.monitoringAll[index].segundoNombre}",
                          )),
                          DataCell(CustomText(
                            title: controller
                                .monitoringAll[index].guardia!.nombre
                                .toString(),
                          )),
                          DataCell(CustomText(
                            title:
                                controller.monitoringAll[index].equipo!.nombre,
                          )),
                          DataCell(CustomText(
                            title: controller
                                .monitoringAll[index].entrenador!.nombre,
                          )),
                          DataCell(CustomText(
                            title: controller
                                .monitoringAll[index].condicion!.nombre,
                          )),
                          DataCell(CustomText(
                            title: DateFormat('dd/MM/yyyy').format(controller
                                .monitoringAll[index].fechaRealMonitoreo!),
                          )),
                          DataCell(CustomText(
                            title: (controller.monitoringAll[index].estado == 2
                                ? "Completado"
                                : "Pendiente"),
                          )),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 3, bottom: 3),
                              child: Row(
                                children: [
                                  AppVisibility(
                                    'Visualizar_monitoreo',
                                    child: Expanded(
                                      child: _buildIconButton(
                                          'Ver',
                                          Icons.remove_red_eye_sharp,
                                          AppTheme.greenColor, () async {
                                        await createMonitoringController
                                            .searchMonitoringDetailById(
                                                context,
                                                controller
                                                    .monitoringAll[index].key!);

                                        await controller
                                            .listarEstadoEntrenamientoPorId(
                                                context,
                                                controller.monitoringAll[index]
                                                    .codigoMcp!,
                                                createMonitoringController
                                                    .selectedEstadoEntrenamientoKey
                                                    .value!);
                                        controller.screen.value =
                                            MonitoringSearchScreen
                                                .viewMonitoring;
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppVisibility(
                                    'Editar_monitoreo',
                                    child: Expanded(
                                      child: _buildIconButton(
                                          'Editar',
                                          Icons.edit,
                                          AppTheme.primaryColor, () async {
                                        await createMonitoringController
                                            .searchMonitoringDetailById(
                                                context,
                                                controller
                                                    .monitoringAll[index].key!);
                                        await controller
                                            .listarEstadoEntrenamientoPorId(
                                                context,
                                                controller.monitoringAll[index]
                                                    .codigoMcp!,
                                                createMonitoringController
                                                    .selectedEstadoEntrenamientoKey
                                                    .value!);

                                        controller.screen.value =
                                            MonitoringSearchScreen
                                                .editMonitoring;
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppVisibility(
                                    'Eliminar_monitoreo',
                                    child: Expanded(
                                      child: _buildIconButton(
                                          'Eliminar',
                                          Icons.delete,
                                          AppTheme.errorColor, () async {
                                        onDelete(
                                            context,
                                            createMonitoringController,
                                            controller
                                                .monitoringAll[index].key!,
                                            controller
                                                .monitoringAll[index].estado!);
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildSeccionResultadoTablaPaginado()
          ],
        ),
      );
    });
  }

  Widget _buildIconButton(
      String toolTip, IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      tooltip: toolTip,
      icon: Icon(
        icon,
        color: color,
        size: 18,
      ),
      onPressed: onPressed,
    );
  }

  void onDelete(BuildContext contextapp,
      CreateMonitoringController createController, int key, int estado) async {
    await showDialog(
      context: contextapp,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: DeleteReasonWidget(
              entityType: 'Monitoreo',
              isMotivoRequired: (estado == 2),
              onCancel: () {
                Navigator.pop(context);
              },
              onConfirm: (motivo) async {
                // motivoEliminacion = motivo;
                if (motivo.isEmpty && estado == 2) {
                  createController.mostrarErroresValidacion(
                      context, ['Debes ingresar el motivo de eliminación']);
                  return;
                }
                Navigator.pop(context);
                createController.modelMonitoring.motivoEliminado = motivo;
                createController.modelMonitoring.key = key;
                final state =
                    await createController.deleteMonitoring(contextapp);
                if (state) {
                  await controller.searchMonitoring();
                }
              },
            ),
          ),
        );
      },
    );
  }

  SizedBox actionsWidgets(
      CreateMonitoringController createMonitoringController) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: const Text(
              'Monitoreo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isSmallScreen)
            const Spacer(
              flex: 2,
            ),
          AppVisibility(
            'Exportar_lista_monitoreos',
            child: Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await controller.downloadExcel();
                },
                icon: const Icon(
                  Icons.download,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                label: const Text(
                  "Descargar",
                  style: TextStyle(fontSize: 16, color: AppTheme.primaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppVisibility(
            'Nuevo_monitoreo',
            child: Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  controller.screen.value =
                      MonitoringSearchScreen.newMonitoring;
                  controller.clearFilter();
                  createMonitoringController.clearModel();
                },
                icon: const Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Nuevo monitoreo",
                  style: TextStyle(
                      fontSize: 16, color: AppTheme.primaryBackground),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionResultadoTablaPaginado() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
              'Mostrando ${controller.currentPage.value * controller.rowsPerPage.value - controller.rowsPerPage.value + 1} - '
              '${controller.currentPage.value * controller.rowsPerPage.value > controller.totalRecords.value ? controller.totalRecords.value : controller.currentPage.value * controller.rowsPerPage.value} '
              'de ${controller.totalRecords.value} registros',
              style: const TextStyle(fontSize: 14),
            )),
        Obx(
          () => Row(
            children: [
              const Text("Items por página: "),
              DropdownButton<int>(
                value: controller.rowsPerPage.value > 0 &&
                        controller.rowsPerPage.value <= 50
                    ? controller.rowsPerPage.value
                    : null,
                items: [10, 20, 50]
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.rowsPerPage.value = value;
                    controller.currentPage.value = 1;
                    controller.searchMonitoring(
                        pageNumber: controller.currentPage.value,
                        pageSize: value);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.currentPage.value > 1
                    ? () {
                        controller.currentPage.value--;
                        controller.searchMonitoring(
                            pageNumber: controller.currentPage.value,
                            pageSize: controller.rowsPerPage.value);
                      }
                    : null,
              ),
              Text(
                  '${controller.currentPage.value} de ${controller.totalPages.value}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed:
                    controller.currentPage.value < controller.totalPages.value
                        ? () {
                            controller.currentPage.value++;
                            controller.searchMonitoring(
                                pageNumber: controller.currentPage.value,
                                pageSize: controller.rowsPerPage.value);
                          }
                        : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
