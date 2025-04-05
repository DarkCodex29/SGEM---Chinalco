import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/modules/pages/administracion/historial/historial_modificaciones_controller.dart';
import 'package:sgem/modules/pages/administracion/historial/widget/filter_modificaciones_widget.dart';
import 'package:sgem/modules/pages/administracion/rolesPermisos/roles_permisos.dart';
import 'package:sgem/shared/widgets/custom_table/custom_table.dart';

class HistorialModificacionesPage extends StatelessWidget {
  const HistorialModificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(HistorialModificacionesController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          const FilterModificacionesWidget(),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Historial de modificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.primaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: ctr.downloadExcel,
                            icon: const Icon(
                              Icons.download,
                              size: 18,
                              color: AppTheme.backgroundBlue,
                            ),
                            label: const Text(
                              'Descargar excel',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.backgroundBlue,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () {
                        debugPrint('Result: ${ctr.historialAll.length}');
                        final result = ctr.historialAll;

                        if (result.isEmpty) {
                          return const Center(
                            child: Text('No se encontraron resultados'),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: CustomTable(
                            headers: const [
                              'Fecha de acción',
                              'Usuario de acción',
                              'Tabla',
                              'Acción',
                              'Registro',
                            ],
                            data: result,
                            builder: (historial) => ctr
                                .historialFormat(historial)
                                .map((e) => Center(child: Text(e)))
                                .toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          ButtonRolesPermisos(
            labelButton: 'Regresar',
            onTap: Get.find<AdministracionController>().screenPop,
          ),
        ],
      ),
    );
  }
}
