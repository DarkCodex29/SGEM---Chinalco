import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/consulta.personal/consulta.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/entrenamiento.personal.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.entrenamiento/entrenamiento.nuevo.controller.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.entrenamiento/entrenamiento.nuevo.modal.dart';
import 'package:sgem/modules/pages/consulta.personal/entrenamiento/modales/nuevo.modulo/entrenamiento.modulo.nuevo.dart';
import 'package:sgem/modules/pages/consulta.personal/personal/nuevo.personal.controller.dart';
import 'package:sgem/shared/modules/entrenamiento.modulo.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.motivo.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.confirmation.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/widgets.dart';

class EntrenamientoPersonalPage extends StatefulWidget {
  EntrenamientoPersonalPage({
    required this.controllerPersonal,
    required this.onCancel,
    super.key,
    this.isDeepLink = false,
  }) {}
  final PersonalSearchController controllerPersonal;
  final VoidCallback onCancel;
  final bool isDeepLink;

  @override
  State<EntrenamientoPersonalPage> createState() =>
      _EntrenamientoPersonalPageState();
}

class _EntrenamientoPersonalPageState extends State<EntrenamientoPersonalPage> {
  @override
  void initState() {
    ctr.fetchTrainings(
      context,
      widget.controllerPersonal.selectedPersonal.value!.key!,
    );
    controllerNuevoPersonal.loadPersonalPhoto(
      widget.controllerPersonal.selectedPersonal.value!.inPersonalOrigen!,
    );
  }

  final NuevoPersonalController controllerNuevoPersonal =
      Get.put(NuevoPersonalController());

  final EntrenamientoPersonalController ctr =
      Get.put(EntrenamientoPersonalController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isDeepLink
          ? AppBar(
              title: const Text(
                'Visualizar entrenamientos',
                style: TextStyle(
                  color: AppTheme.backgroundBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: const Color(0xFFF2F6FF),
              automaticallyImplyLeading: false,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 1.15,
          child: Column(
            children: [
              _buildPersonalDetails(),
              const SizedBox(height: 16),
              widget.isDeepLink
                  ? const SizedBox()
                  : _buildTrainingListHeaderWithButton(context),
              const SizedBox(height: 16),
              Expanded(child: _buildTrainingList(context)),
              const SizedBox(height: 16),
              widget.isDeepLink
                  ? const SizedBox()
                  : _buildRegresarButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetails() {
    return ResponsiveBuilder(
      breakpoints: const ScreenBreakpoints(
        desktop: 1300,
        tablet: 1024,
        watch: 200,
      ),
      builder: (_, device) {
        return ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white),
          ),
          title: const Text(
            "Datos del personal",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.backgroundBlue,
            ),
          ),
          initiallyExpanded: isDesktop(device)
              ? true
              : widget.isDeepLink
                  ? false
                  : true,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          onExpansionChanged: (value) {
            // controller.isExpanded.value = value;
          },
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final photo =
                            controllerNuevoPersonal.personalPhoto.value;

                        if (photo?.isEmpty ?? true) {
                          return const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user_avatar.png'),
                            radius: 60,
                            backgroundColor: Colors.grey,
                          );
                        }

                        return CircleAvatar(
                          backgroundImage: MemoryImage(photo!),
                          onBackgroundImageError: (exception, stackTrace) {
                            Logger('EntrenamientoPersonalPage').severe(
                              'Error al cargar la imagen',
                              exception,
                              stackTrace,
                            );
                          },
                          radius: 60,
                          backgroundColor: Colors.grey,
                        );
                      }),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos del Personal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ResponsiveBuilder(
                              breakpoints: const ScreenBreakpoints(
                                desktop: 1300,
                                tablet: 1024,
                                watch: 200,
                              ),
                              builder: (_, SizingInformation device) {
                                return Row(
                                  children: [
                                    _buildCustomTextField(
                                      'Código',
                                      widget.controllerPersonal.selectedPersonal
                                              .value?.codigoMcp ??
                                          '',
                                      width: 130,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (device.deviceScreenType ==
                                        DeviceScreenType.desktop) ...[
                                      _buildCustomTextField(
                                        'Nombres y Apellidos',
                                        '${widget.controllerPersonal.selectedPersonal.value?.primerNombre ?? ''} '
                                            '${widget.controllerPersonal.selectedPersonal.value?.apellidoPaterno ?? ''} '
                                            '${widget.controllerPersonal.selectedPersonal.value?.apellidoMaterno ?? ''}',
                                        width: 330,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      _buildCustomTextField(
                                        'Guardia',
                                        widget
                                                .controllerPersonal
                                                .selectedPersonal
                                                .value
                                                ?.guardia!
                                                .nombre ??
                                            '',
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ResponsiveBuilder(
                    breakpoints: const ScreenBreakpoints(
                      desktop: 1300,
                      tablet: 1024,
                      watch: 200,
                    ),
                    builder: (_, device) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (device.deviceScreenType !=
                              DeviceScreenType.desktop) ...[
                            _buildCustomTextField(
                              'Nombres y Apellidos',
                              '${widget.controllerPersonal.selectedPersonal.value?.primerNombre ?? ''} '
                                  '${widget.controllerPersonal.selectedPersonal.value?.apellidoPaterno ?? ''} '
                                  '${widget.controllerPersonal.selectedPersonal.value?.apellidoMaterno ?? ''}',
                              width: 330,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            _buildCustomTextField(
                              'Guardia',
                              widget.controllerPersonal.selectedPersonal.value
                                      ?.guardia!.nombre ??
                                  '',
                              width: 70,
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTextField(
    String label,
    String initialValue, {
    double width = 200,
  }) {
    final controller = TextEditingController(text: initialValue);
    return SizedBox(
      width: width,
      child: CustomTextField(
        label: label,
        controller: controller,
        isReadOnly: true,
        maxLines: 1,
      ),
    );
  }

  Widget _buildTrainingListHeaderWithButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Entrenamientos',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        AppVisibility(
          'Nuevo_entrenamiento',
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
            child: ElevatedButton.icon(
              onPressed: () async {
                final ultimoEntrenamiento =
                    await ctr.obtenerUltimoEntrenamientoPorPersona(
                  context,
                  widget.controllerPersonal.selectedPersonal.value!.id,
                );

                if (!context.mounted) return;

                if (widget.controllerPersonal.selectedPersonal.value != null) {
                  if (!(ultimoEntrenamiento?.isTraining ?? false)) {
                    await EntrenamientoNuevoModal(
                      data: widget.controllerPersonal.selectedPersonal.value!,
                      assetsNotAvailable: ctr.assetsNotAvailable(),
                    ).show(context);
                  } else {
                    const message = 'No puede agregar un nuevo entrenamiento, '
                        'mientras el modulo anterior no ha sido '
                        'completado o paralizado';
                    const MensajeValidacionWidget(
                      errores: [message],
                    ).show(context);
                  }
                } else {
                  const MensajeValidacionWidget(
                    errores: ['No se ha seleccionado un personal'],
                  ).show(context);
                }
              },
              icon: const Icon(
                Icons.add,
                size: 15,
                color: Colors.white,
              ),
              label: const Text(
                'Nuevo entrenamiento',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 2,
                minimumSize: const Size(230, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingList(BuildContext context) {
    return Obx(() {
      if (ctr.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        );
      }
      if (ctr.trainingList.isEmpty) {
        return const Center(child: Text('No hay entrenamientos disponibles'));
      }
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return widget.isDeepLink
              ? ExpansionTile(
                  childrenPadding: const EdgeInsets.all(0),
                  title: const Text(
                    'Entrenamiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.backgroundBlue,
                    ),
                  ),
                  initiallyExpanded: true,
                  children: [
                    ColoredBox(
                      color: AppTheme.alternateColor,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight - kTextTabBarHeight - 2,
                        child: ListView.builder(
                          itemCount: ctr.trainingList.length,
                          itemBuilder: (context, index) {
                            final training = ctr.trainingList[index];
                            return _buildTrainingCard(training, context);
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: ctr.trainingList.length,
                  itemBuilder: (context, index) {
                    final training = ctr.trainingList[index];
                    return _buildTrainingCard(training, context);
                  },
                );
        },
      );
    });
  }

  Axis isAxis(SizingInformation device) {
    if (device.deviceScreenType == DeviceScreenType.desktop) {
      return Axis.horizontal;
    } else {
      return Axis.vertical;
    }
  }

  bool isDesktop(SizingInformation device) {
    if (device.deviceScreenType == DeviceScreenType.desktop) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildTrainingCard(
    EntrenamientoModulo training,
    BuildContext context,
  ) {
    return Card(
      color: const Color(0xFFF2F6FF),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ResponsiveBuilder(
          breakpoints: const ScreenBreakpoints(
            desktop: 1024,
            tablet: 1024,
            watch: 200,
          ),
          builder: (_, device) {
            return Column(
              children: [
                Flex(
                  direction: isAxis(device),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomTextField(
                          'Equipo',
                          training.equipo!.nombre!,
                        ),
                        _buildCustomTextField(
                          'Estado de avance actual',
                          training.estadoEntrenamiento!.nombre!.toLowerCase() ==
                                  'autorizado'
                              ? 'Finalizado'
                              : training.modulo!.nombre!,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              color: _getColorByEstado(
                                training.estadoEntrenamiento!.key!,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildCustomTextField(
                              'Estado entrenamiento',
                              training.estadoEntrenamiento!.nombre!,
                            ),
                          ],
                        ),
                        _buildCustomTextField(
                          'Entrenador',
                          training.entrenador!.nombre!,
                          width: 330,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomTextField(
                          'Fecha inicio',
                          _formatDate(training.fechaInicio),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.radio_button_checked,
                              color: _getColorByHorasEntrenamiento(
                                training.inHorasAcumuladas!,
                                training.inTotalHoras!,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildCustomTextField(
                              'Horas de entrenamiento',
                              _getEstadoAvanceActual(
                                training.estadoEntrenamiento!.nombre!,
                                training.inHorasAcumuladas!,
                                training.inTotalHoras!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomTextField(
                          'Fecha fin',
                          _formatDate(
                            training.fechaTermino,
                          ), // Formatear las fechas correctamente
                        ),
                        _buildCustomTextField(
                          'Nota teórica',
                          '${training.inNotaTeorica}', // Mostrar las notas teóricas y prácticas
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCustomTextField(
                          'Condición',
                          training.condicion!.nombre!,
                          width: 260,
                        ),
                        _buildCustomTextField(
                          'Nota práctica',
                          '${training.inNotaPractica}',
                        ),
                      ],
                    ),
                    widget.isDeepLink
                        ? const SizedBox()
                        : _buildActionButtons(context, training),
                  ],
                ),
                Obx(
                  () {
                    final modulos =
                        ctr.obtenerModulosPorEntrenamiento(training.key!);
                    return ExpansionTile(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text(
                        'Módulos del entrenamiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: modulos.isNotEmpty
                          ? modulos
                              .map(
                                (m) => device.deviceScreenType ==
                                        DeviceScreenType.desktop
                                    ? _buildModuleDetails(
                                        context,
                                        m,
                                        isParaliced:
                                            training.isParaliced ?? false,
                                      )
                                    : _buildModuleDetailsVertical(
                                        context,
                                        m,
                                        isParaliced:
                                            training.isParaliced ?? false,
                                      ),
                              )
                              .toList()
                          : [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('No hay módulos disponibles'),
                              ),
                            ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildModuleDetails(
    BuildContext context,
    EntrenamientoModulo modulo, {
    bool isParaliced = false,
  }) {
    final isCompleted = modulo.isCompleted ?? false;
    final moduloKey = modulo.modulo?.key ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 36),
      //crear otro widget vertival
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_on,
                  color: modulo.estadoEntrenamiento!.nombre!.toLowerCase() ==
                          'completo'
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  modulo.modulo!.nombre!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Horas de entrenamiento:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${modulo.inHorasAcumuladas}/${modulo.inTotalHoras}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Visibility(
              visible: moduloKey > 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horas minestar:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${modulo.inHorasMinestar}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nota teórica:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${modulo.inNotaTeorica}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nota práctica:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${modulo.inNotaPractica}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const Spacer(),
          widget.isDeepLink
              ? const SizedBox()
              : Row(
                  children: [
                    if (isCompleted || isParaliced)
                      IconButton(
                        tooltip: 'Ver modulo',
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () async {
                          final success = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: EntrenamientoModuloNuevo(
                                    eModulo: modulo,
                                    inPersona: modulo.inPersona,
                                    inEntrenamientoModulo: modulo.key,
                                    inEntrenamiento:
                                        modulo.inActividadEntrenamiento,
                                    //isEdit: true,
                                    isView: true,
                                  ),
                                ),
                              );
                            },
                          );
                          if (success != null && success) {
                            ctr.fetchTrainings(
                              context,
                              widget.controllerPersonal.selectedPersonal.value!
                                  .key!,
                            );
                          }
                        },
                      ),
                    if (!isCompleted && !isParaliced)
                      AppVisibility(
                        'Editar_modulo',
                        child: IconButton(
                          tooltip: 'Editar modulo',
                          icon: const Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () => ctr.onEditModule(
                            context,
                            modulo,
                            widget.controllerPersonal.selectedPersonal.value!
                                .key!,
                          ),
                        ),
                      ),
                    if (!isCompleted && !isParaliced)
                      AppVisibility(
                        'Eliminar_modulo',
                        child: IconButton(
                          tooltip: 'Eliminar modulo',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            var motivoEliminacion = '';
                            await showDialog<void>(
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: DeleteReasonWidget(
                                      entityType:
                                          'módulo - ${modulo.modulo!.nombre}',
                                      isMotivoRequired: false,
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirm: (motivo) {
                                        motivoEliminacion = motivo;
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );

                            if (motivoEliminacion.isEmpty) return;

                            var confirmarEliminar = false;
                            await showDialog<void>(
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: ConfirmDeleteWidget(
                                      itemName: 'módulo',
                                      entityType: '',
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirm: () {
                                        confirmarEliminar = true;
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            );

                            if (!confirmarEliminar) return;

                            final success =
                                await ctr.eliminarModulo(context, modulo);

                            if (success) {
                              await showDialog<void>(
                                context: context,
                                builder: (context) {
                                  return const SuccessDeleteWidget();
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al eliminar el módulo.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildModuleDetailsVertical(
    BuildContext context,
    EntrenamientoModulo modulo, {
    bool isParaliced = false,
  }) {
    final isCompleted = modulo.isCompleted ?? false;
    final moduloKey = modulo.modulo?.key ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      //crear otro widget vertival
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.radio_button_on,
                color: modulo.estadoEntrenamiento!.nombre!.toLowerCase() ==
                        'completo'
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                modulo.modulo!.nombre!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Horas de entrenamiento:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${modulo.inHorasAcumuladas}/${modulo.inTotalHoras}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Visibility(
            visible: moduloKey > 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Horas minestar:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${modulo.inHorasMinestar}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nota teórica:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${modulo.inNotaTeorica}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nota práctica:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${modulo.inNotaPractica}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // const Spacer(),
          widget.isDeepLink
              ? const SizedBox()
              : Row(
                  children: [
                    if (isCompleted || isParaliced)
                      IconButton(
                        tooltip: 'Ver modulo',
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () async {
                          final success = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: EntrenamientoModuloNuevo(
                                    eModulo: modulo,
                                    inPersona: modulo.inPersona,
                                    inEntrenamientoModulo: modulo.key,
                                    inEntrenamiento:
                                        modulo.inActividadEntrenamiento,
                                    //isEdit: true,
                                    isView: true,
                                  ),
                                ),
                              );
                            },
                          );
                          if (success != null && success) {
                            ctr.fetchTrainings(
                              context,
                              widget.controllerPersonal.selectedPersonal.value!
                                  .key!,
                            );
                          }
                        },
                      ),
                    if (!isCompleted && !isParaliced)
                      IconButton(
                        tooltip: 'Editar modulo',
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.primaryColor,
                        ),
                        onPressed: () => ctr.onEditModule(
                          context,
                          modulo,
                          widget
                              .controllerPersonal.selectedPersonal.value!.key!,
                        ),
                      ),
                    if (!isCompleted && !isParaliced)
                      IconButton(
                        tooltip: 'Eliminar modulo',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          var motivoEliminacion = '';
                          await showDialog<void>(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: DeleteReasonWidget(
                                    entityType:
                                        'módulo - ${modulo.modulo!.nombre}',
                                    isMotivoRequired: false,
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: (motivo) {
                                      motivoEliminacion = motivo;
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );

                          if (motivoEliminacion.isEmpty) return;

                          var confirmarEliminar = false;
                          await showDialog<void>(
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () => FocusScope.of(context).unfocus(),
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: ConfirmDeleteWidget(
                                    itemName: 'módulo',
                                    entityType: '',
                                    onCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onConfirm: () {
                                      confirmarEliminar = true;
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );

                          if (!confirmarEliminar) return;

                          final success =
                              await ctr.eliminarModulo(context, modulo);

                          if (success) {
                            await showDialog<void>(
                              context: context,
                              builder: (context) {
                                return const SuccessDeleteWidget();
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al eliminar el módulo.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    EntrenamientoModulo training,
  ) {
    if (training.isParaliced ?? false) {
      return IconButton(
        tooltip: 'Ver entrenamiento',
        icon: const Icon(
          Icons.remove_red_eye,
          color: AppTheme.primaryColor,
        ),
        onPressed: () async {
          final controllerModal = Get.put(EntrenamientoNuevoController());
          await controllerModal.getEquiposAndConditions();

          if (!context.mounted) return;

          await EntrenamientoNuevoModal(
            data: widget.controllerPersonal.selectedPersonal.value!,
            training: training,
            isEdit: true,
          ).show(context);
        },
      );
    }

    final modulos = ctr.obtenerModulosPorEntrenamiento(training.key!)
      ..sort((a, b) => a.inModulo!.compareTo(b.inModulo!));

    final lastModule = modulos.isNotEmpty ? modulos.last.inModulo : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            AppVisibility(
              'Editar_entrenamiento',
              child: IconButton(
                tooltip: 'Editar entrenamiento',
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () async {
                  final controllerModal =
                      Get.put(EntrenamientoNuevoController());
                  await controllerModal.getEquiposAndConditions();

                  if (!context.mounted) return;

                  final updatedTraining = await EntrenamientoNuevoModal(
                    data: widget.controllerPersonal.selectedPersonal.value!,
                    isEdit: true,
                    training: training,
                    lastModulo: lastModule,
                    assetsNotAvailable: ctr.assetsNotAvailable(),
                  ).show(context);

                  log('Entrenamiento: $updatedTraining');
                  if (updatedTraining != null) {
                    final success = await ctr.actualizarEntrenamiento(
                      context,
                      updatedTraining,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Entrenamiento actualizado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            if (!(training.isAuthorized ?? false))
              AppVisibility(
                'Eliminar_entrenamiento',
                child: IconButton(
                  tooltip: 'Eliminar entrenamiento',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    var motivoEliminacion = '';

                    log('Entrenamiento: ${training.key!}');
                    final response = await ctr.entrenamientoService
                        .obtenerUltimoModuloPorEntrenamiento(
                      training.key!,
                    );
                    final ultimoModulo = response.data!;
                    log('Eliminar Entrenamiento: ${ultimoModulo.inModulo}');
                    if (ultimoModulo.inModulo != null &&
                        ultimoModulo.inModulo! >= 1) {
                      log('Existe modulo ${ultimoModulo.inModulo}');
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return const MensajeValidacionWidget(
                            errores: [
                              'No se puede eliminar un ENTRENAMIENTO que ya tiene un MODULO registrado',
                            ],
                          );
                        },
                      );
                      return;
                    }

                    if (!context.mounted) return;

                    await showDialog<void>(
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: DeleteReasonWidget(
                              entityType: 'entrenamiento',
                              isMotivoRequired: false,
                              onCancel: () {
                                Navigator.pop(context);
                              },
                              onConfirm: (motivo) {
                                motivoEliminacion = motivo;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    );

                    if (motivoEliminacion.isEmpty) return;

                    var confirmarEliminar = false;
                    await showDialog<void>(
                      context: context,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () => FocusScope.of(context).unfocus(),
                          child: Padding(
                            padding: MediaQuery.of(context).viewInsets,
                            child: ConfirmDeleteWidget(
                              itemName: 'entrenamiento',
                              entityType: '',
                              onCancel: () {
                                Navigator.pop(context);
                              },
                              onConfirm: () {
                                confirmarEliminar = true;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                    );

                    if (!confirmarEliminar) return;
                    try {
                      final success =
                          await ctr.eliminarEntrenamiento(context, training);
                      if (success) {
                        await showDialog<void>(
                          context: context,
                          builder: (context) {
                            return const SuccessDeleteWidget();
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Error al eliminar el entrenamiento.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      log('Error eliminando el entrenamiento: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Error eliminando el entrenamiento: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            if (training.isTraining ?? false)
              AppVisibility(
                'Nuevo_modulo',
                child: IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryColor,
                  ),
                  tooltip: 'Nuevo modulo',
                  onPressed: () => ctr.onCreateModule(
                    context,
                    training,
                    widget.controllerPersonal.selectedPersonal.value!.key!,
                  ),
                ),
              ),
          ],
        ),
        if (training.isAuthorized ?? false)
          Row(
            children: [
              AppVisibility(
                'Imprimir_diploma',
                child: IconButton(
                  tooltip: 'Ver diploma',
                  icon: const Icon(
                    Icons.stars_sharp,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    ctr.selectedTraining.value = training;
                    widget.controllerPersonal.showDiploma();
                  },
                ),
              ),
              AppVisibility(
                'Imprimir_autorización',
                child: IconButton(
                  tooltip: 'Ver certificado',
                  icon: const Icon(
                    Icons.file_copy_sharp,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    ctr.selectedTraining.value = training;
                    widget.controllerPersonal.showCertificado();
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRegresarButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: widget.onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text('Regresar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getEstadoAvanceActual(
    String estadoEntrenamiento,
    int horasAcumuladas,
    int totalHoras,
  ) {
    return '$horasAcumuladas / $totalHoras';
  }

  Color _getColorByEstado(int estado) {
    switch (estado) {
      case 13:
        return Colors.green; // AUTORIZADO
      case 11:
        return Colors.orange; // ENTRENANDO
      case 12:
        return Colors.red; //PARALIZADO
      default:
        return Colors.grey;
    }
  }

  Color _getColorByHorasEntrenamiento(
    int horasAcumuladas,
    int horasEntrenamiento,
  ) {
    if (horasAcumuladas >= horasEntrenamiento) {
      return Colors.green;
    }
    return Colors.orange;
  }
}
