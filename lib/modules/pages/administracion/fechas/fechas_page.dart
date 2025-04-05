import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion_controller.dart';
import 'package:sgem/modules/pages/administracion/administracion_enum.dart';
import 'package:sgem/modules/pages/administracion/fechas/fechas_controller.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';
import 'package:sgem/shared/widgets/dropDown/simple_app_dropdown.dart';
import 'package:sgem/shared/widgets/table/custom.table.text.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';

class FechasPage extends StatelessWidget {
  FechasPage({super.key});

  final fechasController = Get.put(FechasController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormSection(context),
          const SizedBox(height: 20),
          _buildResultSection(),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                fechasController.clearFilter();
                await fechasController.obtenerFechasPaginado(
                    pageSize: 10, pageNumber: 1);
                Get.find<AdministracionController>().screenPop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child:
                  const Text('Regresar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Obx(() {
      return ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white),
        ),
        title: Text(
          "Filtro de Búsqueda",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                // Expanded(
                //   child: CustomDropdownGlobal(
                //     labelText: 'Año',
                //     dropdownKey: 'años',
                //     hintText: 'Seleccione un año',
                //     noDataHintText: 'No hay años',
                //     controller: fechasController.anioController,
                //     initialValue: fechasController.selectedAnioKey.value,
                //     onChanged: (value) {
                //       fechasController.selectedAnioKey.value = value!;
                //       print(value);
                //     },
                //   ),
                // ),
                _buildAniosDropdown(),
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 23),
                    child: CustomDropdownGlobal(
                      labelText: 'Guardia',
                      dropdownKey: 'guardiaFiltro',
                      hintText: 'Seleccione una guardia',
                      noDataHintText: 'No hay guardias',
                      controller: fechasController.guardiaController,
                      initialValue: fechasController.selectedGuardiaKey.value,
                      onChanged: (value) {
                        print(value);
                        fechasController.selectedGuardiaKey.value = value!;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CustomTextField(
                    label: 'Rango de fecha de inicio',
                    controller: fechasController.rangoFechaController,
                    icon: const Icon(Icons.calendar_month),
                    onIconPressed: () async {
                      await fechasController.seleccionarFecha(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  fechasController.clearFilter();
                  await fechasController.obtenerFechasPaginado(
                      pageSize: 10, pageNumber: 1);
                  //controller.resetControllers();
                  //controller.searchPersonal();
                },
                icon: const Icon(
                  Icons.cleaning_services,
                  size: 18,
                  color: AppTheme.primaryText,
                ),
                label: const Text(
                  "Limpiar",
                  style: TextStyle(fontSize: 16, color: AppTheme.primaryText),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppTheme.alternateColor),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  fechasController.currentPage.value = 1;
                  fechasController.totalPages.value = 0;
                  fechasController.totalRecords.value = 0;
                  await fechasController.obtenerFechasPaginado(
                      pageSize: 10, pageNumber: 1);
                  //await controller.searchPersonal();
                },
                icon: const Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  "Buscar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          )
        ],
      );
    });
  }

  Widget _buildAniosDropdown() {
    List<OptionValue> tmpList = List.from(fechasController.anios);
    var options =
        tmpList.map((option) => (option.key!, option.nombre!)).toList();
    return Obx(() {
      return Expanded(
          child: SimpleAppDropdown(
        label: 'Año',
        hint: 'Año',
        options: options,
        initialValue: fechasController.selectedAnioKey.value.key,
        onChanged: (value) async {
          if (options.length > 0) {
            final selectedOption = options.firstWhere(
              (option) => option.$1 == value,
            );

            fechasController.selectedAnioKey.value =
                OptionValue(key: selectedOption.$1, nombre: selectedOption.$2);
          }
        },
      ));
    });
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AppButton.blue(
              text: 'Carga de cronograma',
              onPressed: () {
                fechasController.clearCronogramaForm();
                Get.find<AdministracionController>()
                    .changePage(AdministracionScreen.fechasCronograma);
              },
              icon: Icons.sync,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () {
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable2(
                          showBottomBorder: true,
                          columnSpacing: 20.0,
                          // minWidth: 2190.0,
                          dataRowHeight: 52.0,
                          headingRowHeight: 44.0,
                          fixedColumnsColor: Colors.red,
                          decoration:
                              BoxDecoration(color: Colors.grey.shade200),
                          columns: [
                            DataColumn2(
                              fixedWidth: 140,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Años",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            DataColumn2(
                              //fixedWidth: 170,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Guardia",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            DataColumn2(
                              //fixedWidth: 170,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Fecha inicio",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            DataColumn2(
                              //fixedWidth: 170,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Fecha fin",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            DataColumn2(
                              //fixedWidth: 170,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Usuario registro",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            DataColumn2(
                              //fixedWidth: 170,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "Fecha registro",
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                          rows: List.generate(
                            fechasController.fechas.length,
                            (index) {
                              return DataRow(
                                color: MaterialStateProperty.all(Colors.white),
                                cells: [
                                  DataCell(CustomText(
                                    title: fechasController.fechas[index].anio
                                        .toString(),
                                  )),
                                  DataCell(CustomText(
                                    title: fechasController
                                        .fechas[index].guardia.nombre,
                                  )),
                                  DataCell(CustomText(
                                    title: DateFormat('dd/MM/yyyy').format(
                                        fechasController
                                            .fechas[index].fechaInicio),
                                  )),
                                  DataCell(CustomText(
                                    title: DateFormat('dd/MM/yyyy').format(
                                        fechasController
                                            .fechas[index].fechaFin),
                                  )),
                                  DataCell(CustomText(
                                    title: fechasController
                                        .fechas[index].usuarioModificacion,
                                  )),
                                  DataCell(CustomText(
                                    title: DateFormat('dd/MM/yyyy').format(
                                        fechasController
                                            .fechas[index].fechaModificacion),
                                  )),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    _buildSeccionResultadoTablaPaginado(),
                  ],
                ),
              );
            },
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
              'Mostrando del ${fechasController.currentPage.value * fechasController.rowsPerPage.value - fechasController.rowsPerPage.value + 1} al '
              '${fechasController.currentPage.value * fechasController.rowsPerPage.value > fechasController.totalRecords.value ? fechasController.totalRecords.value : fechasController.currentPage.value * fechasController.rowsPerPage.value} '
              'de ${fechasController.totalRecords.value} registros',
              style: const TextStyle(fontSize: 14),
            )),
        Obx(
          () => Row(
            children: [
              const Text("Items por página: "),
              DropdownButton<int>(
                value: fechasController.rowsPerPage.value > 0 &&
                        fechasController.rowsPerPage.value <= 50
                    ? fechasController.rowsPerPage.value
                    : null,
                items: [10, 20, 50]
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    fechasController.rowsPerPage.value = value;
                    fechasController.currentPage.value = 1;
                    fechasController.obtenerFechasPaginado(
                        pageNumber: fechasController.currentPage.value,
                        pageSize: value);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: fechasController.currentPage.value > 1
                    ? () {
                        fechasController.currentPage.value--;
                        fechasController.obtenerFechasPaginado(
                            pageNumber: fechasController.currentPage.value,
                            pageSize: fechasController.rowsPerPage.value);
                      }
                    : null,
              ),
              Text(
                  '${fechasController.currentPage.value} de ${fechasController.totalPages.value}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: fechasController.currentPage.value <
                        fechasController.totalPages.value
                    ? () {
                        fechasController.currentPage.value++;
                        fechasController.obtenerFechasPaginado(
                            pageNumber: fechasController.currentPage.value,
                            pageSize: fechasController.rowsPerPage.value);
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
