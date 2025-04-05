import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/modules/pages/capacitaciones/capacitacion.controller.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/save/widget.save.personal.confirmation.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../shared/modules/capacitacion.carga.masiva.excel.dart';
import '../../../../shared/widgets/dynamic.table/dynamic.table.cabecera.dart';
import 'capacitacion.carga.masiva.controller.dart';

class CapacitacionCargaMasivaPage extends StatelessWidget {
  const CapacitacionCargaMasivaPage({super.key, required this.onCancel});
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final CapacitacionCargaMasivaController controller =
        Get.put(CapacitacionCargaMasivaController());

    final CapacitacionController capacitacionController =
        Get.put(CapacitacionController());

    return Scaffold(
      body: _buildCapacitacionCargaMasivaPage(
          controller, context, capacitacionController),
    );
  }

  Widget _buildCapacitacionCargaMasivaPage(
      CapacitacionCargaMasivaController controller,
      BuildContext context,
      CapacitacionController capacitacionController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //_buildSeccionFiltros(context, controller),
              const SizedBox(
                height: 20,
              ),
              _buildSeccionResultado(context, controller),
              const SizedBox(
                height: 20,
              ),
              _buildRegresarButton(context, controller, capacitacionController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccionResultado(
      BuildContext context, CapacitacionCargaMasivaController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSeccionResultadoBarraSuperior(context, controller),
          const SizedBox(
            height: 20,
          ),
          _buildSeccionResultadoContador(controller),
          const SizedBox(
            height: 20,
          ),
          _buildSeccionResultadoTabla(controller),
          const SizedBox(
            height: 20,
          ),
          _buildSeccionResultadoTablaPaginado(controller),
        ],
      ),
    );
  }

  Widget _buildSeccionResultadoBarraSuperior(
      BuildContext context, CapacitacionCargaMasivaController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            controller.cargarArchivo();
          },
          tooltip: 'Adjuntar archivo',
          icon: const Icon(
            Icons.attach_file,
            color: AppTheme.primaryColor,
            size: 32,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: CustomTextField(
            label: "Archivo",
            controller: controller.archivoController,
            isReadOnly: true,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        //if (controller.archivoController.text.isNotEmpty)
        IconButton(
          onPressed: () {
            controller.limpiar();
          },
          tooltip: 'Eliminar',
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Row(
          children: _buildBotonesAccion(context, controller),
        ),
      ],
    );
  }

  Widget _buildSeccionResultadoContador(
      CapacitacionCargaMasivaController controller) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text(
                  "Cantidad de registros: ${controller.totalRecords}",
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              )),
          const SizedBox(
            width: 20,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.20),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text(
                  "Correctos: ${controller.correctRecords}",
                  style: TextStyle(color: Colors.blueAccent.shade400),
                ),
              )),
          const SizedBox(
            width: 20,
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.20),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Text(
                  "Con errores: ${controller.errorRecords}",
                  style: const TextStyle(color: Colors.red),
                ),
              )),
        ],
      );
    });
  }

  Widget _buildSeccionResultadoTabla(
      CapacitacionCargaMasivaController controller) {
    List<String> cabecera = [
      'Código MCP',
      'DNI',
      'Nombres y apellidos',
      'Guardia',
      'Codigo Entrenador',
      'Entrenador responsable',
      'Nombre capacitación',
      'Categoría',
      'Empresa de capacitación',
      'Fecha de inicio',
      'Fecha de término',
      'Horas',
      'Nota teórica',
      'Nota práctica',
    ];
    return Obx(
      () {
        var rowsToShow = controller.cargaMasivaExcel
            .take(controller.rowsPerPage.value)
            .toList();

        return Column(
          children: [
            DynamicTableCabecera(cabecera: cabecera),
            _buildSeccionResultadoTablaData(rowsToShow, controller),
          ],
        );
      },
    );
  }

  Widget _buildSeccionResultadoTablaData(
      List<CapacitacionCargaMasivaExcel> data,
      CapacitacionCargaMasivaController controller) {
    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        child: Obx(() {
          return Column(
            children: controller.cargaMasivaResultadosPaginados.map((fila) {
              var styleError = const TextStyle(color: Colors.redAccent);
              var styleRegular = const TextStyle(color: AppTheme.primaryText);
              List<Widget> celdas = [
                fila.esCorrectoCodigo
                    ? Text(fila.codigo, style: styleRegular)
                    : Text(fila.mensajeCodigo, style: styleError),
                fila.esCorrectoDni
                    ? Text(fila.dni, style: styleRegular)
                    : Text(fila.mensajeDni, style: styleError),
                fila.esCorrectoNombres
                    ? Text(fila.nombres, style: styleRegular)
                    : Text(fila.mensajeNombres, style: styleError),
                fila.esCorrectoGuardia
                    ? Text(fila.guardia, style: styleRegular)
                    : Text(fila.mensajeGuardia, style: styleError),
                fila.esCorrectoCodigoEntrenador
                    ? Text(fila.codigoEntrenador.toString(),
                        style: styleRegular)
                    : Text(fila.mensajeCodigoEntrenador, style: styleError),
                fila.esCorrectoEntrenador
                    ? Text(fila.entrenador, style: styleRegular)
                    : Text(fila.mensajeEntrenador, style: styleError),
                fila.esCorrectoNombreCapacitacion
                    ? Text(fila.nombreCapacitacion, style: styleRegular)
                    : Text(fila.mensajeNombreCapacitacion, style: styleError),
                fila.esCorrectoCategoria
                    ? Text(fila.categoria, style: styleRegular)
                    : Text(fila.mensajeCategoria, style: styleError),
                fila.esCorrectoEmpresa
                    ? Text(fila.empresa, style: styleRegular)
                    : Text(fila.mensajeEmpresa, style: styleError),
                fila.esCorrectoFechaInicio
                    ? Text(_formatoFecha(fila.fechaInicio), style: styleRegular)
                    : Text(fila.mensajeFechaInicio, style: styleError),
                fila.esCorrectoFechaTermino
                    ? Text(_formatoFecha(fila.fechaTermino),
                        style: styleRegular)
                    : Text(fila.mensajeFechaTermino, style: styleError),
                fila.esCorrectoHoras
                    ? Text(fila.horas?.toString() ?? '', style: styleRegular)
                    : Text(fila.mensajeHoras, style: styleError),
                fila.esCorrectoNotaTeorica
                    ? Text(fila.notaTeorica?.toString() ?? '',
                        style: styleRegular)
                    : Text(fila.mensajeNotaTeorica, style: styleError),
                fila.esCorrectoNotaPractica
                    ? Text(fila.notaPractica?.toString() ?? '',
                        style: styleRegular)
                    : Text(fila.mensajeNotaPractica, style: styleError),
              ];
              return _buildFila(celdas, fila.esValido);
            }).toList(),
          );
        }),
      ),
    );
  }

  String _formatoFecha(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
  }

  Widget _buildFila(List<Widget> celdas, bool esCorrecto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        color: esCorrecto
            ? Colors.blueAccent.withOpacity(0.20)
            : Colors.redAccent.withOpacity(0.20),
        child: Row(
            children: celdas.map((celda) {
          return Expanded(flex: 1, child: celda);
        }).toList()),
      ),
    );
  }

  List<Widget> _buildBotonesAccion(
      BuildContext context, CapacitacionCargaMasivaController controller) {
    return [
      ElevatedButton.icon(
        onPressed: () {
          controller.previsualizarCarga(context);
        },
        icon: const Icon(
          Icons.upload_rounded,
          size: 18,
          color: AppTheme.infoColor,
        ),
        label: const Text(
          "Previsualizar carga",
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
      const SizedBox(width: 10),
      ElevatedButton.icon(
        onPressed: () {
          controller.descargarPlantilla(context);
        },
        icon: const Icon(
          Icons.download_rounded,
          size: 18,
          color: AppTheme.primaryBackground,
        ),
        label: const Text(
          "Descargar plantilla",
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
    ];
  }

  Widget _buildSeccionResultadoTablaPaginado(
      CapacitacionCargaMasivaController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
              'Mostrando ${controller.currentPage.value * controller.rowsPerPage.value - controller.rowsPerPage.value + 1} - '
              '${controller.currentPage.value * controller.rowsPerPage.value > controller.totalRecords.value ? controller.totalRecords.value : controller.currentPage.value * controller.rowsPerPage.value} '
              'de ${controller.totalRecords.value} registros',
              style: const TextStyle(fontSize: 14),
            )),
        Obx(
          () => Row(
            children: [
              const Text("Items por página: "),
              DropdownButton<int>(
                value: controller.rowsPerPage.value > 0 &&
                        controller.rowsPerPage.value <= 50
                    ? controller.rowsPerPage.value
                    : null,
                items: [10, 20, 50]
                    .map((value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.rowsPerPage.value = value;
                    controller.currentPage.value =
                        1; // Reiniciar a la primera página
                    // Recalcular el total de páginas
                    controller.totalPages.value =
                        (controller.totalRecords.value /
                                controller.rowsPerPage.value)
                            .ceil();
                    controller.goToPage(1); // Mostrar la primera página
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: controller.currentPage.value > 1
                    ? () {
                        controller.previousPage();
                      }
                    : null,
              ),
              Text(
                  '${controller.currentPage.value} de ${controller.totalPages.value}'),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed:
                    controller.currentPage.value < controller.totalPages.value
                        ? () {
                            controller.nextPage();
                          }
                        : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegresarButton(
      BuildContext context,
      CapacitacionCargaMasivaController controller,
      CapacitacionController capacitacionController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            controller.limpiar();
            onCancel();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: const Text("Regresar", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
          onPressed: () async {
            if (controller.esConfirmacionValida()) {
              // Proceder con la carga
              var response = await controller.confirmarCarga(context);
              if (response) {
                final totalRecords = controller.correctRecords.value;
                showDialog(
                  context: context,
                  builder: (context) {
                    return MensajeGuardadoWidget(
                      title: 'Se realizó la carga de ${totalRecords} registros',
                    );
                  },
                );

                controller.limpiar();

                onCancel();
                capacitacionController.buscarCapacitaciones();
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MensajeValidacionWidget(
                        errores: ['Ha sucedido un error']);
                  },
                );
              }
            } else {
              // Mostrar un mensaje de advertencia si las condiciones no se cumplen

              if (controller.totalRecords == controller.errorRecords) {
                controller.mostrarErroresValidacion(
                    context, ['No hay registros correctos para cargar.']);
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return MensajeValidacionWidget(
                      errores: [
                        'Para confirmar la cargar debe realizar lo siguiente:',
                        'Seleccione un archivo, previsualice la carga.',
                        'Asegúrese de que todos los registros estén validados y sin errores'
                      ],
                    );
                  },
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          child: const Text("Confirmar carga",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
