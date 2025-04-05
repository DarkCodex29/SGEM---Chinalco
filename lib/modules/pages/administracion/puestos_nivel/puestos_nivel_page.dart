import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/modules/pages/administracion/puestos_nivel/puestos_nivel_controller.dart';
import 'package:sgem/modules/pages/administracion/puestos_nivel/widget/modal_puestos_nivel.dart';

import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/custom_table/custom_table.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';

class PuestosNivelPage extends StatelessWidget {
  const PuestosNivelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<PuestosNivelController>();

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
                        final refresh = await showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return ModalPuestosNivel();
                          },
                        );
                        if (refresh == true) {
                          ctr.search(
                            context,
                          );
                        }
                      },
                      icon: Icons.add,
                      text: 'Nuevo Puesto',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(
                      () {
                        final result = ctr.puestosNivelResultados;

                        if (result.isEmpty) {
                          return const Center(
                            child: Text('No se encontraron resultados'),
                          );
                        }

                        return CustomTable(
                          headers: const [
                            'Código',
                            'Puesto',
                            'Nivel',
                            'Usuario registro',
                            'Fecha de registro',
                            'Usuario modificación',
                            'Fecha de modificación',
                            'Estado',
                          ],
                          data: result,
                          builder: (puestosNivelData) {
                            return [
                              Center(
                                child: Text(puestosNivelData.key.toString()),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData.puesto.nombre.toString(),
                                ),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData.nivel.nombre.toString(),
                                ),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData.userRegister,
                                ),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData
                                      .dateRegister.formatExtended, //
                                ),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData.usuarioModifica,
                                ),
                              ),
                              Center(
                                child: Text(
                                  puestosNivelData
                                      .fechaRegistro.formatExtended, //
                                ),
                              ),
                              Center(
                                child: ActiveBox(
                                  isActive: puestosNivelData.activo == 'N'
                                      ? false
                                      : true,
                                ),
                              ),
                            ];
                          },
                          actions: (mdetalle) => [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final refresh = await showAdaptiveDialog(
                                  context: context,
                                  builder: (context) {
                                    return ModalPuestosNivel(
                                      detalle: mdetalle,
                                    );
                                  },
                                );
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
