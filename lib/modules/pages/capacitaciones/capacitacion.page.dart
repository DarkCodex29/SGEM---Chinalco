import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/capacitaciones/capacitacion.controller.dart';
import 'package:sgem/modules/pages/capacitaciones/capacitacion.enum.dart';
import 'package:sgem/modules/pages/capacitaciones/carga.masiva/capacitacion.carga.masiva.page.dart';
import 'package:sgem/modules/pages/capacitaciones/nueva.capacitacion/nueva.capacitacion.page.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.motivo.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.confirmation.dart';
import 'package:sgem/shared/widgets/delete/widget.delete.personal.dart';
import 'package:sgem/shared/widgets/dropDown/custom.dropdown.global.dart';
import 'package:sgem/shared/widgets/widgets.dart';

class CapacitacionPage extends StatelessWidget {
  CapacitacionPage({required this.onCancel, super.key});
  final VoidCallback onCancel;
  final DateTime today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CapacitacionController());
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () {
            return Text(
              controller.screenPage.value.descripcion(),
              style: const TextStyle(
                color: AppTheme.backgroundBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        backgroundColor: AppTheme.primaryBackground,
      ),
      body: Obx(() {
        switch (controller.screenPage.value) {
          case CapacitacionScreen.none:
            return _buildCapacitacionPage(
              controller,
              context,
            );
          case CapacitacionScreen.nuevaCapacitacion:
            return NuevaCapacitacionPage(
              isEditMode: false,
              isViewing: false,
              onCancel: controller.showCapacitacionPage,
            );
          case CapacitacionScreen.editarCapacitacion:
            return NuevaCapacitacionPage(
              dni: controller.selectedCapacitacion.value!.numeroDocumento,
              codigoMcp: controller.selectedCapacitacion.value!.codigoMcp,
              isEditMode: true,
              isViewing: false,
              capacitacionKey: controller.selectedCapacitacion.value!.key,
              onCancel: controller.showCapacitacionPage,
            );
          case CapacitacionScreen.visualizarCapacitacion:
            return NuevaCapacitacionPage(
              dni: controller.selectedCapacitacion.value!.numeroDocumento,
              codigoMcp: controller.selectedCapacitacion.value!.codigoMcp,
              capacitacionKey: controller.selectedCapacitacion.value!.key,
              isEditMode: false,
              isViewing: true,
              onCancel: controller.showCapacitacionPage,
            );
          case CapacitacionScreen.cargaMasivaCapacitacion:
            return CapacitacionCargaMasivaPage(
              onCancel: controller.showCapacitacionPage,
            );
        }
      }),
    );
  }

  Widget _buildCapacitacionPage(
    CapacitacionController controller,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSeccionConsulta(context, controller),
              const SizedBox(
                height: 20,
              ),
              _buildSeccionResultado(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccionConsulta(
    BuildContext context,
    CapacitacionController controller,
  ) {
    return ExpansionTile(
      initiallyExpanded: controller.isExpanded.value,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white),
      ),
      title: const Text(
        'Filtro de Búsqueda',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              _buildSeccionConsultaPrimeraFila(controller),
              _buildSeccionConsultaSegundaFila(controller),
              _buildSeccionConsultaTerceraFila(context, controller),
              _buildSeccionConsultaCuartaFila(context, controller),
              _buildBotonesAccion(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionResultado(
      BuildContext context, CapacitacionController controller) {
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
          _buildSeccionResultadoBarraSuperior(controller),
          const SizedBox(
            height: 20,
          ),
          _buildSeccionResultadoTabla(context, controller),
          const SizedBox(
            height: 20,
          ),
          _buildSeccionResultadoTablaPaginado(controller),
        ],
      ),
    );
  }

  Widget _buildSeccionConsultaPrimeraFila(CapacitacionController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomTextField(
            label: 'Código MCP',
            controller: controller.codigoMcpController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomTextField(
            label: 'DNI',
            controller: controller.numeroDocumentoController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomDropdownGlobal(
            labelText: 'Guardia',
            dropdownKey: 'guardiaFiltro',
            hintText: 'Selecciona guardia',
            noDataHintText: 'No se encontraron guardias',
            controller: controller.dropdownController,
            onChanged: (value) {
              controller.dropdownController.selectValue('guardiaFiltro', value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaSegundaFila(CapacitacionController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomTextField(
            label: 'Nombres',
            controller: controller.nombresController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomTextField(
            label: 'Apellido Paterno',
            controller: controller.apellidoPaternoController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomTextField(
            label: 'Apellido Materno',
            controller: controller.apellidoMaternoController,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaTerceraFila(
    BuildContext context,
    CapacitacionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomDropdownGlobal(
            labelText: 'Capacitación',
            dropdownKey: 'capacitacion',
            hintText: 'Selecciona capacitación',
            noDataHintText: 'No se encontraron capacitaciones',
            controller: controller.dropdownController,
            onChanged: (value) {
              controller.dropdownController.selectValue('capacitacion', value);
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomDropdownGlobal(
            labelText: 'Categoría',
            dropdownKey: 'categoria',
            hintText: 'Selecciona categoría',
            noDataHintText: 'No se encontraron categorías',
            controller: controller.dropdownController,
            onChanged: (value) {
              controller.actualizarOpcionesEmpresaCapacitadora();
              controller.isValidateCategoria.value = true;
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Obx(() {
            return CustomDropdownGlobal(
              labelText: 'Empresa de capacitación',
              dropdownKey: 'empresaCapacitadora',
              hintText: 'Selecciona empresa de capacitación',
              noDataHintText: 'No se encontraron empresas',
              controller: controller.dropdownController,
              isReadOnly: !controller.isValidateCategoria.value,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaCuartaFila(
    BuildContext context,
    CapacitacionController controller,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: CustomDropdownGlobal(
            labelText: 'Entrenador',
            dropdownKey: 'entrenador',
            hintText: 'Selecciona entrenador',
            noDataHintText: 'No se encontraron entrenadores',
            controller: controller.dropdownController,
            // isReadOnly: !controller.isValidateCategoria.value,
            onChanged: (nuevaSeleccion) {
              controller.dropdownController.selectValue(
                'entrenador',
                nuevaSeleccion,
              );
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomTextField(
            label: 'Rango de Fecha Inicio',
            controller: controller.rangoFechaController,
            icon: const Icon(Icons.calendar_month),
            onIconPressed: () async {
              await controller.seleccionarFecha(context);
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        const Expanded(
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildBotonesAccion(CapacitacionController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            controller.clearFields();
            await controller.buscarCapacitaciones();
            //controller.isExpanded.value = false;
          },
          icon: const Icon(
            Icons.cleaning_services,
            size: 18,
            color: AppTheme.primaryText,
          ),
          label: const Text(
            'Limpiar',
            style: TextStyle(fontSize: 16, color: AppTheme.primaryText),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppTheme.alternateColor),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () async {
            await controller.buscarCapacitaciones();
            controller.isExpanded.value = true;
          },
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
            padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 18),
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }

/*
  Future<DateTimeRange?> _selectDateRange(
      BuildContext context, CapacitacionController controller) async {
    DateTimeRange selectedDateRange = DateTimeRange(
      start: today.subtract(const Duration(days: 7)),
      end: today,
    );

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      barrierDismissible: true,
      saveText: 'Aceptar',
      helpText: 'Seleccione fechas',
      cancelText: 'Cancelar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.black,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                elevation: 3,
                foregroundColor: Colors.red, // button text color
              ),
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: SizedBox(
              child: child,
              height: 500,
              width: 400,
            ),
          ),
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      //controller.rangoFechaController.text =
      //'${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
      //controller.fechaInicio = picked.start;
      //controller.fechaTermino = picked.end;
    }
  }
*/

  Widget _buildSeccionResultadoBarraSuperior(
    CapacitacionController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Capacitaciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: SizedBox.shrink(),
        ),
        const SizedBox(width: 10),
        AppVisibility(
          'Carga_masiva_de_capacitaciones',
          child: ElevatedButton.icon(
            onPressed: () {
              log('Mostrar carga masiva');
              controller.showCargaMasivaCapacitacion();
              // log('Cargar capacitaciones');
              // controller.buscarCapacitaciones();
            },
            icon: const Icon(
              Icons.refresh,
              size: 18,
              color: AppTheme.infoColor,
            ),
            label: const Text(
              'Carga masiva',
              style: TextStyle(fontSize: 16, color: AppTheme.infoColor),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AppVisibility(
          'Exportar_lista_capacitaciones',
          child: ElevatedButton.icon(
            onPressed: () async {
              await controller.downloadExcel();
            },
            icon: const Icon(
              Icons.download,
              size: 18,
              color: AppTheme.primaryColor,
            ),
            label: const Text(
              'Descargar Excel',
              style: TextStyle(fontSize: 16, color: AppTheme.primaryColor),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AppVisibility(
          'Nueva_capacitacion',
          child: ElevatedButton.icon(
            onPressed: () {
              controller.showNuevaCapacitacion();
            },
            icon: const Icon(
              Icons.add,
              size: 18,
              color: AppTheme.primaryBackground,
            ),
            label: const Text(
              'Nueva Capacitación',
              style: TextStyle(fontSize: 16, color: AppTheme.primaryBackground),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionResultadoTabla(
      BuildContext context, CapacitacionController controller) {
    return Obx(
      () {
        if (controller.isLoadingCapacitacionResultados.value) {
          return const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!controller.isLoadingCapacitacionResultados.value &&
            controller.capacitacionResultados.isEmpty) {
          return const Center(child: Text('No se encontraron resultados'));
        }

        final rowsToShow = controller.capacitacionResultados
            .take(controller.rowsPerPage.value)
            .toList();

        return Column(
          children: [
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              child: _buildSeccionResultadoTablaCabezera(),
            ),
            SizedBox(
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: rowsToShow.map((entrenamiento) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(entrenamiento.codigoMcp!),
                          ),
                          Expanded(
                            child: Text(entrenamiento.numeroDocumento!),
                          ),
                          Expanded(
                            child: Text(entrenamiento.nombreCompleto!),
                          ),
                          Expanded(
                            child: Text(
                              entrenamiento.guardia.nombre!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(entrenamiento.entrenador.nombre!),
                          ),
                          Expanded(
                            child: Text(entrenamiento.capacitacion.nombre!),
                          ),
                          Expanded(
                            child: Text(entrenamiento.categoria.nombre!),
                          ),
                          Expanded(
                            child: Text(
                              entrenamiento.empresaCapacitadora.nombre!,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(entrenamiento.fechaInicio!),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(entrenamiento.fechaTermino!),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entrenamiento.inTotalHoras.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entrenamiento.inNotaTeorica == null
                                  ? ''
                                  : entrenamiento.inNotaTeorica.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entrenamiento.inNotaPractica == null
                                  ? ''
                                  : entrenamiento.inNotaPractica.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: entrenamiento.isFranjaVerde
                                ? SizedBox.shrink()
                                : Row(
                                    children: [
                                      AppVisibility(
                                        'Visualizar_capacitacion',
                                        child: Expanded(
                                          child: _buildIconButton(
                                              'Visualizar',
                                              Icons.remove_red_eye,
                                              AppTheme.primaryColor, () {
                                            controller.selectedCapacitacion
                                                .value = entrenamiento;
                                            controller.showVerCapacitacion(
                                              entrenamiento.key!,
                                            );
                                          }),
                                        ),
                                      ),
                                      AppVisibility(
                                        'Editar_capacitacion',
                                        child: Expanded(
                                          child: _buildIconButton(
                                            'Editar',
                                            Icons.edit,
                                            AppTheme.primaryColor,
                                            () async {
                                              if (entrenamiento.key != null) {
                                                controller.selectedCapacitacion
                                                    .value = entrenamiento;
                                                controller
                                                    .showEditarCapacitacion(
                                                  entrenamiento.key!,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      AppVisibility(
                                        'Eliminar_capacitacion',
                                        child: Expanded(
                                          child: _buildIconButton(
                                            'Eliminar',
                                            Icons.delete,
                                            AppTheme.errorColor,
                                            () async {
                                              controller.selectedCapacitacion
                                                  .value = entrenamiento;
                                              String? motivoEliminacion;

                                              await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return GestureDetector(
                                                    //onTap: () =>
                                                    //  FocusScope.of(context)
                                                    //    .unfocus(),
                                                    child: Padding(
                                                      padding:
                                                          MediaQuery.of(context)
                                                              .viewInsets,
                                                      child: DeleteReasonWidget(
                                                        entityType:
                                                            'capacitacion',
                                                        isMotivoRequired: true,
                                                        onCancel: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        onConfirm: (motivo) {
                                                          motivoEliminacion =
                                                              motivo;
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );

                                              if (motivoEliminacion == null ||
                                                  motivoEliminacion!.isEmpty) {
                                                return;
                                              }

                                              bool confirmarEliminar = false;

                                              if (controller
                                                      .selectedCapacitacion
                                                      .value !=
                                                  null) {
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () =>
                                                          FocusScope.of(context)
                                                              .unfocus(),
                                                      child: Padding(
                                                        padding: MediaQuery.of(
                                                                context)
                                                            .viewInsets,
                                                        child:
                                                            ConfirmDeleteWidget(
                                                          itemName: '',
                                                          entityType:
                                                              'capacitación',
                                                          onCancel: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          onConfirm: () {
                                                            confirmarEliminar =
                                                                true;
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                log('Error: No hay capacitación seleccionada');
                                                return;
                                              }

                                              if (!confirmarEliminar) {
                                                return;
                                              }

                                              try {
                                                final bool success =
                                                    await controller
                                                        .eliminarCapacitacion(
                                                  motivoEliminacion!,
                                                );
                                                if (success == true) {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const SuccessDeleteWidget();
                                                    },
                                                  );
                                                  //controller.buscarCapacitaciones();
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Error al eliminar la capacitación. Intenta nuevamente.',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                log('Error eliminando la capacitación: $e');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error eliminando la capacitación: $e',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeccionResultadoTablaCabezera() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Código MCP',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'DNI',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Nombres y Apellidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Guardia',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Entrenador responsable',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Capacitacion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Categoria',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Empresa de capacitacion',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Fecha de inicio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Fecha de termino',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Horas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Nota teorica',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Nota practica',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Acciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionResultadoTablaPaginado(
    CapacitacionController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            'Mostrando ${controller.currentPage.value * controller.rowsPerPage.value - controller.rowsPerPage.value + 1} - '
            '${controller.currentPage.value * controller.rowsPerPage.value > controller.totalRecords.value ? controller.totalRecords.value : controller.currentPage.value * controller.rowsPerPage.value} '
            'de ${controller.totalRecords.value} registros',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Obx(
          () => Row(
            children: [
              const Text('Items por página: '),
              DropdownButton<int>(
                value: controller.rowsPerPage.value > 0 &&
                        controller.rowsPerPage.value <= 50
                    ? controller.rowsPerPage.value
                    : null,
                items: [10, 20, 50]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.rowsPerPage.value = value;
                    controller.currentPage.value = 1;
                    controller.buscarCapacitaciones(
                      pageNumber: controller.currentPage.value,
                      pageSize: value,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.currentPage.value > 1
                    ? () {
                        controller.currentPage.value--;
                        controller.buscarCapacitaciones(
                          pageNumber: controller.currentPage.value,
                          pageSize: controller.rowsPerPage.value,
                        );
                      }
                    : null,
              ),
              Text(
                '${controller.currentPage.value} de ${controller.totalPages.value}',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed:
                    controller.currentPage.value < controller.totalPages.value
                        ? () {
                            controller.currentPage.value++;
                            controller.buscarCapacitaciones(
                              pageNumber: controller.currentPage.value,
                              pageSize: controller.rowsPerPage.value,
                            );
                          }
                        : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    String toolTip,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return IconButton(
      tooltip: toolTip,
      icon: Icon(
        icon,
        color: color,
        size: 20,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildRegresarButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        ),
        child: const Text('Regresar', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
