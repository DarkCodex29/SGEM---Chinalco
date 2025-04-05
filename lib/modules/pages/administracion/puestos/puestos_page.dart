import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/modules/pages/administracion/puestos/puestos_controller.dart';
import 'package:sgem/modules/pages/administracion/puestos/widget/modal_puestos.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom_table/custom_table.dart';

class PuestosPage extends StatelessWidget {
  const PuestosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(PuestosController(
      context,
    ));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                            await const ModalPuestos().show(context);

                        if (refresh == true) {
                          ctr.search(
                            context,
                          );
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
                            'Equipo',
                            'Código equipo',
                            'Usuario modificación',
                            'Fecha de modificación',
                            'Tiene relacion',
                            'Estado',
                          ],
                          data: result,
                          builder: (mdetalle) {
                            return [
                              Center(
                                child: Text(mdetalle.key?.format ?? 'N/A'),
                              ),
                              Center(child: Text(mdetalle.nombre)),
                              Center(
                                child: Text('pendiente'),
                              ),
                              Center(
                                child: Text(mdetalle.usuarioModifica ?? 'N/A'),
                              ),
                              Center(
                                child: Text(
                                  mdetalle.fechaModifica?.formatExtended ??
                                      'N/A',
                                ),
                              ),
                              Center(
                                child: Text(
                                    mdetalle.detalleRelacion?.nombre ?? 'N/A'),
                              ),
                              if (mdetalle.activo == null)
                                Center(
                                  child: const Text('N/A'),
                                )
                              else
                                Center(
                                  child: ActiveBox(
                                    isActive: mdetalle.activo == 'S',
                                  ),
                                ),
                            ];
                          },
                          actions: (mdetalle) => [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final refresh =
                                    await ModalPuestos(detalle: mdetalle)
                                        .show(context);

                                if (refresh == true) {
                                  ctr.search(
                                    context,
                                  );
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
