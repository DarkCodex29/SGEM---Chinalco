import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/puestos_nivel/puestos_nivel_controller.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/widgets/auto_complete/auto_complete_widget.dart';
import 'package:sgem/shared/models/puesto.dart';
import 'package:sgem/shared/models/puestos_nivel.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class ModalPuestosNivel extends StatelessWidget {
  final PuestosNivel? detalle;

  ModalPuestosNivel({Key? key, this.detalle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(PuestosNivelController());
    Logger('ModalPuestos').info('Detalle: $detalle');

    final isEdit = detalle != null;
    if (isEdit) {
      ctr.estadoController.value = detalle!.activo == 'S' ? 1 : 0;
      ctr.nivelesDC.value = detalle!.nivel.key;
    } else {
      ctr.nivelesDC.value = null;
      ctr.estadoController.value = null;
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth > 500 ? 500 : constraints.maxWidth,
              maxHeight:
                  constraints.maxHeight > 800 ? 800 : constraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundBlue,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Editar Puesto' : 'Nuevo Puesto',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: context.pop,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                  child: Column(
                    children: [
                      if (isEdit)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Código: ${detalle!.key.format}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      isEdit
                          ? SizedBox()
                          : _puestosWidget(context, ctr, constraints),
                      SizedBox(height: 15),
                      MaestraAppDropdown(
                        label: 'Niveles',
                        options: (ctr) => ctr.nivelResultados.toOptionValue(),
                        hasAllOption: false,
                        controller: ctr.nivelesDC,
                        isRequired: true,
                      ),
                      SizedBox(height: 10),
                      MaestraAppDropdown(
                        options: (ctr) => ctr.estados,
                        isRequired: true,
                        controller: ctr.estadoController,
                        label: 'Estado',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton.white(
                      onPressed: context.pop,
                      text: 'Cerrar',
                    ),
                    AppButton.blue(
                      onPressed: isEdit
                          ? () {
                              final nivel = ctr.nivelesDC.selectedOption;
                              ctr.key = detalle!.key;
                              if (ctr.nombrePuesto == '' &&
                                  ctr.keyPuesto == 0) {
                                ctr.nombrePuesto = detalle!.puesto.nombre!;
                                ctr.keyPuesto = detalle!.puesto.key!;
                              }
                              if (nivel?.nombre == null) {
                                ctr.nombreNivel = detalle!.nivel.nombre!;
                                ctr.keyNivel = detalle!.nivel.key!;
                              } else {
                                ctr.nombreNivel = nivel!.nombre!;
                                ctr.keyNivel = nivel.key!;
                              }

                              ctr.updatePuestosNivel(context);
                            }
                          : () => ctr.savePuestosNivel(context),
                      text: 'Guardar',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Obx _puestosWidget(BuildContext context, PuestosNivelController ctr,
      BoxConstraints constraints) {
    return Obx(() {
      final resultx = ctr.puestosResult;
      if (resultx.isEmpty) {}

      return CustomAutocompleteWidget(
        width: constraints.maxWidth * 0.25 - 15,
        labelText: 'Puesto',
        hintText: 'Buscar Puesto',
        displayStringForOption: (Puesto puesto) => puesto.nombre,
        isRequired: true,
        onChangedSelect: (Puesto puesto) {
          ctr.puesto = puesto;
          ctr.nombrePuesto = puesto.nombre;
          ctr.keyPuesto = puesto.key;
        },
        optionsBuilder: (TextEditingValue textEditingValue) async {
          final puestoText = textEditingValue.text;

          if (puestoText.length < 4) {
            return const Iterable<Puesto>.empty();
          }

          await ctr.searchPuesto(context, puestoText).then((value) {
            final filteredResults = ctr.puestosResult
                .where((i) =>
                    i.nombre.toLowerCase().contains(puestoText.toLowerCase()))
                .toList();

            if (filteredResults.isNotEmpty) {
              ctr.puestosResult(filteredResults);
            }
            return filteredResults;
          }).onError((error, stackTrace) {
            return ctr.puestosResult;
          });
          return ctr.puestosResult;
        },
      );
    });
  }
}
