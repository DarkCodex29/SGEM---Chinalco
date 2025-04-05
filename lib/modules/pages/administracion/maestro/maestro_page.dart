import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/app_text_field.dart';
import 'package:sgem/shared/widgets/custom_table/custom_table.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class MaestroPage extends StatelessWidget {
  const MaestroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(MaestroController());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const FilterTile(),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
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
                      onPressed: () async {
                        final refresh =
                            await const MaestroEditView().show(context);

                        if (refresh == true) {
                          ctr.search();
                        }
                      },
                      icon: Icons.add,
                      text: 'Nuevo elemento',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(
                      () {
                        debugPrint('Result: ${ctr.result.length}');
                        final result = ctr.result;

                        if (result.isEmpty) {
                          return const Center(
                            child: Text('No se encontraron resultados'),
                          );
                        }

                        return CustomTable(
                          headers: const [
                            'Código',
                            'Maestro',
                            'Valor',
                            'Usuario modificación',
                            'Fecha de modificación',
                            'Estado',
                          ],
                          data: result,
                          builder: (mdetalle) {
                            return [
                              Center(
                                  child: Text(mdetalle.key?.format ?? 'N/A')),
                              Center(
                                  child:
                                      Text(mdetalle.maestro.nombre ?? 'N/A')),
                              Center(child: Text(mdetalle.nombre)),
                              Center(
                                  child:
                                      Text(mdetalle.usuarioModifica ?? 'N/A')),
                              Center(
                                child: Text(
                                    mdetalle.fechaModifica?.formatExtended ??
                                        'N/A'),
                              ),
                              Center(
                                child: ActiveBox(
                                  isActive: mdetalle.activo,
                                ),
                              ),
                            ];
                          },
                          actions: (mdetalle) => [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final refresh =
                                    await MaestroEditView(detalle: mdetalle)
                                        .show(context);

                                if (refresh == true) {
                                  ctr.search();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: Get.find<AdministracionController>().screenPop,
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
}

class FilterTile extends StatelessWidget {
  const FilterTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<MaestroController>();
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
                children: <Widget>[
                  Expanded(
                    child: MaestraAppDropdown(
                      options: (ctr) => ctr.maestros,
                      controller: ctr.maestroController,
                      label: 'Maestro',
                      hasAllOption: true,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AppTextField(
                      label: 'Valor',
                      controller: ctr.valorController,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: MaestraAppDropdown(
                      label: 'Estado',
                      options: (ctr) => ctr.estados,
                      controller: ctr.estadoController,
                      hasAllOption: true,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: ctr.clearFilter,
                    icon: const Icon(
                      Icons.cleaning_services,
                      size: 18,
                      color: AppTheme.primaryText,
                    ),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 49,
                        vertical: 18,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppTheme.alternateColor),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: ctr.search,
                    icon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Buscar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 49,
                        vertical: 18,
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
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
