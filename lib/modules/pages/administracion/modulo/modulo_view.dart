import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/administracion.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/custom_table/custom_table.dart';

class ModuloView extends StatelessWidget {
  const ModuloView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(ModuloController(
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
              child: Obx(
                () {
                  final modulos = ctr.modulos;

                  if (modulos.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron resultados'),
                    );
                  }

                  return CustomTable(
                    headers: const [
                      'Módulo',
                      'Horas de cumplimiento',
                      'Nota mínima aprobatoria',
                      'Nota máxima',
                      'Estado',
                      'Usuario modificación',
                      'Fecha modificación',
                    ],
                    data: modulos,
                    builder: (modulo) {
                      return [
                        Center(child: Text(modulo.module)),
                        Center(child: Text(modulo.hours.toString())),
                        Center(child: Text(modulo.minGrade.toString())),
                        Center(child: Text(modulo.maxGrade.toString())),
                        Center(child: ActiveBox(isActive: modulo.status)),
                        Center(child: Text(modulo.userModification)),
                        Center(
                          child: Text(modulo.modificationDate?.format ?? '-'),
                        ),
                      ];
                    },
                    actions: (modulo) => [
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final update = await ModuloEditView(modulo: modulo)
                                .show(context);
                            if (update ?? false) {
                              await ctr.getModulos(
                                context,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
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
