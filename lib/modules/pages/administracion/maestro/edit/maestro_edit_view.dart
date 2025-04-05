import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/maestro/edit/maestro_edit.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/app_button.dart';
import 'package:sgem/shared/widgets/app_text_field.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class MaestroEditView extends StatefulWidget {
  const MaestroEditView({
    super.key,
    this.detalle,
  });

  final Detalle? detalle;

  Future<bool?> show(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (context) => this,
      );

  @override
  State<MaestroEditView> createState() => _MaestroEditViewState();
}

class _MaestroEditViewState extends State<MaestroEditView> {
  @override
  void initState() {
    Get.put(MaestroEditController(context, widget.detalle));
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<MaestroEditController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Logger('MaestroEditView').info('Detalle: ${widget.detalle}');
    final ctr = Get.find<MaestroEditController>();
    final isEdit = widget.detalle != null;

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
                        isEdit ? 'Editar Elemento' : 'Nuevo Elemento',
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
                            'Código: ${widget.detalle!.key.format}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      MaestraAppDropdown(
                        options: (ctr) => ctr.maestros,
                        isRequired: true,
                        controller: ctr.maestroController,
                        readOnly: widget.detalle != null,
                        label: 'Maestro',
                      ),
                      AppTextField(
                        label: 'Valor',
                        isRequired: true,
                        controller: ctr.valorController,
                      ),
                      AppTextField(
                        label: 'Descripción',
                        controller: ctr.descripcionController,
                        maxLines: 3,
                      ),
                      ValueListenableBuilder(
                        valueListenable: ctr.maestroController,
                        builder: (context, value, _) {
                          if (value == null) {
                            return const SizedBox.shrink();
                          }

                          final maestro =
                              ctr.maestroController.selectedOption! as Maestro;
                          final relacion = maestro.maestroRelacion;

                          if (relacion == null) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              if (maestro.key == 5) ...[
                                const SizedBox(height: 10),
                                AppTextField(
                                  label:
                                      'Código Familia de Equipo (Inventario)',
                                  controller: ctr.codigoEquipoController,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 10),
                                AppTextField(
                                  label: 'Código Minestar',
                                  controller: ctr.codigoMinestarController,
                                  isRequired: true,
                                ),
                                const SizedBox(height: 10),
                              ],
                              Obx(() {
                                if (ctr.loading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                return MaestraAppDropdown(
                                  options: (_) => ctr.detailsRelated,
                                  isRequired: true,
                                  controller: ctr.relacionController,
                                  label: relacion.nombre ?? 'Relación',
                                );
                              }),
                            ],
                          );
                        },
                      ),
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
                      onPressed: () => (isEdit
                          ? ctr.updateDetalle
                          : ctr.saveDetalle)(context),
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
}
