import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/modules/pages/administracion/fechas/fechas_controller.dart';
import 'package:sgem/modules/pages/administracion/historial/historial_modificaciones_controller.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';

import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class FilterModificacionesWidget extends StatelessWidget {
  const FilterModificacionesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<HistorialModificacionesController>();
    final fechasController = Get.put(FechasController());
    final width = MediaQuery.of(context).size.width * 0.2;

    return ExpansionTile(
      title: const Text(
        "Filtro de Búsqueda",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: width,
                    child: CustomTextField(
                      label: 'Rango de fecha de inicio',
                      controller: fechasController.rangoFechaController,
                      icon: const Icon(Icons.calendar_month),
                      onIconPressed: () async {
                        await fechasController.seleccionarFecha(context);
                        ctr.rangoFechaController =
                            fechasController.rangoFechaController;
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: width,
                    child: CustomTextField(
                      label: 'Usuario de acción',
                      controller: ctr.usuarioAccion,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: width,
                    child: MaestraAppDropdown(
                      label: 'Tablas',
                      options: (ctr) {
                        return ctr.historialTabla.toOptionValue();
                      },
                      hasAllOption: true,
                      controller: ctr.tablaDC,
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    width: width,
                    child: MaestraAppDropdown(
                      label: 'Accion',
                      options: (ctr) => ctr.historialAccion.toOptionValue(),
                      hasAllOption: true,
                      controller: ctr.accionDC,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.white(
                    onPressed: ctr.clear,
                    icon: Icons.cleaning_services,
                    text: 'Limpiar',
                  ),
                  const SizedBox(width: 10),
                  AppButton.blue(
                    onPressed: ctr.searchHistorial,
                    icon: Icons.cleaning_services,
                    text: 'Buscar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
