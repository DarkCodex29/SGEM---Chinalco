import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion_controller.dart';
import 'package:sgem/modules/pages/administracion/administracion_enum.dart';
import 'package:sgem/modules/pages/administracion/fechas/fechas_controller.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/table/custom.table.text.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';

class CargarCronogramaFechas extends StatefulWidget {
  CargarCronogramaFechas({super.key});

  @override
  State<CargarCronogramaFechas> createState() => _CargarCronogramaFechasState();
}

class _CargarCronogramaFechasState extends State<CargarCronogramaFechas> {
  final FechasController fechasController = Get.put(FechasController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormSection(),
          const SizedBox(height: 20),
          _buildStatistics(),
          const SizedBox(height: 20),
          _buildResultSection(),
          const SizedBox(height: 20),
          _buildSectionButtons()
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => fechasController.adjuntarDocumentos(),
              icon: const Icon(Icons.attach_file, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text('Archivo'),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fechasController.archivosAdjuntos.map((archivo) {
                return Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
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
                                    await fechasController.eliminarArchivo(
                                        archivo['nombre'], archivo['key']);
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
                    // IconButton(
                    //   icon: const Icon(Icons.download, color: Colors.blue),
                    //   onPressed: () {
                    //     fechasController
                    //         .descargarArchivo(archivo);
                    //   },
                    // ),
                  ],
                );
              }).toList(),
            ),
            Expanded(child: Text('')),
            ElevatedButton.icon(
              onPressed: () async {
                await fechasController.previsualizarCarga(
                  context,
                );
                //await controller.searchPersonal();
              },
              icon: const Icon(
                Icons.upload,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                "Previsualizar carga",
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
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () async {
                await fechasController.descargarPlantilla(
                  context,
                );
                //await controller.searchPersonal();
              },
              icon: const Icon(
                Icons.download,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                "Descargar plantilla",
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
        );
      }),
    );
  }

  Widget _buildStatistics() {
    return Obx(() {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'Cantidad de registros: ${fechasController.totalRecordsMasive}',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'Correctos: ${fechasController.totalSuccess}',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'Con errores: ${fechasController.totalErrors}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildResultSection() {
    return Obx(
      () {
        var items = fechasController.cargaMasivaExcel;

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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 450,
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
                          columns: [
                            DataColumn2(
                              fixedWidth: 140,
                              size: ColumnSize.L,
                              label: CustomText(
                                title: "N°",
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
                          ],
                          rows: List.generate(
                            items.length,
                            (index) {
                              return DataRow(
                                color: MaterialStateProperty.all(
                                    index % 2 == 0 + 1
                                        ? (items[index].valido
                                            ? Colors.grey.shade100
                                            : Colors.red.withOpacity(0.2))
                                        : (items[index].valido
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2))),
                                cells: [
                                  DataCell(CustomText(
                                    title: items[index].index.toString(),
                                  )),
                                  DataCell(CustomText(
                                    title: (items[index].esErrorGuardia
                                        ? 'Guardia no existe'
                                        : items[index].guardia),
                                    textColor: (items[index].esErrorGuardia
                                        ? Colors.red
                                        : null),
                                  )),
                                  DataCell(CustomText(
                                    title: (!items[index].esErrorFechaInicio
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(items[index].fechaInicio!)
                                        : items[index].errorFechaInicio),
                                    textColor: (items[index].esErrorFechaInicio
                                        ? Colors.red
                                        : null),
                                  )),
                                  DataCell(CustomText(
                                    title: (!items[index].esErrorFechaFin
                                        ? DateFormat('dd/MM/yyyy')
                                            .format(items[index].fechaFin!)
                                        : items[index].errorFechaFin),
                                    textColor: (items[index].esErrorFechaFin
                                        ? Colors.red
                                        : null),
                                  )),

                                  // DataCell(CustomText(
                                  //   title: items[index].guardia,
                                  // )),
                                  // DataCell(CustomText(
                                  //   title: (items[index].fechaInicio != null
                                  //       ? DateFormat('dd/MM/yyyy')
                                  //           .format(items[index].fechaInicio!)
                                  //       : 'Campo obligatorio'),
                                  //   textColor: (items[index].fechaInicio ==
                                  //           'Campo obligatorio'
                                  //       ? Colors.red
                                  //       : null),
                                  // )),
                                  // DataCell(CustomText(
                                  //   title: (items[index].fechaFin != null
                                  //       ? DateFormat('dd/MM/yyyy')
                                  //           .format(items[index].fechaFin!)
                                  //       : 'Campo obligatorio'),
                                  //   textColor: (items[index].fechaFin ==
                                  //           'Campo obligatorio'
                                  //       ? Colors.red
                                  //       : null),
                                  // )),
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
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.yellow[700],
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Al confirmar la carga sólo se cargarán los registros correctos.',
                    style: TextStyle(fontSize: 11),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccionResultadoTablaPaginado() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
                  'Total:  ${fechasController.totalRecordsMasive.value} registros',
                  style: const TextStyle(fontSize: 12),
                )),
            Text(''),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            fechasController.clearFilter();
            fechasController.clearCronogramaForm();
            await fechasController.obtenerFechasPaginado(
                pageSize: 10, pageNumber: 1);
            Get.find<AdministracionController>()
                .changePage(AdministracionScreen.fechas);
            //await fechasController.previsualizarCarga();
            //await controller.searchPersonal();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(
          width: 20,
        ),

        // ElevatedButton.icon(
        //   onPressed: () async {
        //     fechasController.clearFilter();
        //     fechasController.clearCronogramaForm();
        //     await fechasController.obtenerFechasPaginado(
        //         pageSize: 10, pageNumber: 1);
        //     Get.find<AdministracionController>()
        //         .changePage(AdministracionScreen.fechas);
        //     //await fechasController.previsualizarCarga();
        //     //await controller.searchPersonal();
        //   },
        //   icon: const Icon(
        //     Icons.arrow_back_sharp,
        //     size: 18,
        //     //color: Colors.white,
        //   ),
        //   label: const Text(
        //     "Cancelar",
        //     //style: TextStyle(fontSize: 16, color: Colors.white),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
        //     //backgroundColor: AppTheme.primaryColor,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     elevation: 2,
        //   ),
        // ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final result = await fechasController.grabarCronograma(context);
            if (result) {
              fechasController.clearCronogramaForm();
              fechasController.clearFilter();
              await fechasController.obtenerFechasPaginado();
              Get.find<AdministracionController>()
                  .changePage(AdministracionScreen.fechas);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          child: const Text("Confirmar carga",
              style: TextStyle(color: Colors.white)),
        ),

        // ElevatedButton.icon(
        //   onPressed: () async {
        //     final result =
        //         await fechasController.grabarCronograma(context);
        //     if (result) {
        //       fechasController.clearCronogramaForm();
        //       fechasController.clearFilter();
        //       await fechasController.obtenerFechasPaginado();
        //       Get.find<AdministracionController>()
        //           .changePage(AdministracionScreen.fechas);
        //     }
        //     //await controller.searchPersonal();
        //   },
        //   icon: const Icon(
        //     Icons.save,
        //     size: 18,
        //     //color: Colors.white,
        //   ),
        //   label: const Text(
        //     "Confirmar carga",
        //     //style: TextStyle(fontSize: 16, color: Colors.white),
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
        //     // backgroundColor: AppTheme.primaryColor,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     elevation: 2,
        //   ),
        // ),
      ],
    );
  }
}
