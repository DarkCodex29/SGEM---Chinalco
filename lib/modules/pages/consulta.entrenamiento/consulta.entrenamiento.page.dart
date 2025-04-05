import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/consulta.entrenamiento/consulta.entrenamiento.controller.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/modules/entrenamiento.consulta.dart';
import 'package:sgem/shared/widgets/app_visibility.dart';
import 'package:sgem/shared/widgets/custom.textfield.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';
import 'package:sgem/shared/widgets/dynamic.table/dynamic.table.cabecera.dart';

class ConsultaEntrenamientoPage extends StatelessWidget {
  ConsultaEntrenamientoPage({super.key});

  final DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ConsultaEntrenamientoController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Consulta Entrenamiento",
          style: const TextStyle(
            color: AppTheme.backgroundBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBackground,
      ),
      body: _buildConsultaEntrenamiento(
        controller,
        context,
      ),
    );
  }

  Widget _buildConsultaEntrenamiento(
    ConsultaEntrenamientoController controller,
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
              _buildSeccionResultado(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccionConsulta(
    BuildContext context,
    ConsultaEntrenamientoController controller,
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
              _buildBotonesAccion(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaPrimeraFila(
    ConsultaEntrenamientoController controller,
  ) {
    return Row(
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
          child: MaestraAppDropdown(
            label: 'Equipo',
            hint: 'Selecciona equipo',
            options: (ctr) => ctr.assets.toOptionValue(),
            hasAllOption: true,
            controller: controller.equipoController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: MaestraAppDropdown(
            label: 'Modulo',
            hint: 'Selecciona modulo',
            options: (ctr) => ctr.trainModules.toOptionValue(),
            hasAllOption: true,
            controller: controller.moduloController,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaSegundaFila(
    ConsultaEntrenamientoController controller,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
          child: MaestraAppDropdown(
            label: 'Guardia',
            hint: 'Selecciona guardia',
            hasAllOption: true,
            options: (ctr) => ctr.guardia.toOptionValue(),
            controller: controller.guardiaController,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: MaestraAppDropdown(
            label: 'Estado de entrenamiento',
            hint: 'Selecciona estado de entrenamiento',
            hasAllOption: true,
            options: (ctr) => ctr.trainStatus.toOptionValue(),
            controller: controller.estadoEntrenamientoController,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MaestraAppDropdown(
            label: 'Condicion',
            hint: 'Selecciona condicion',
            options: (ctr) => ctr.trainCondition.toOptionValue(),
            hasAllOption: true,
            controller: controller.condicionController,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionConsultaTerceraFila(
    BuildContext context,
    ConsultaEntrenamientoController controller,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
          child: CustomTextField(
            label: 'Rango de fecha',
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
        Expanded(
          child: CustomTextField(
            label: 'Nombres y Apellidos del personal',
            controller: controller.nombresController,
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

  Widget _buildBotonesAccion(ConsultaEntrenamientoController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            controller.resetControllers();
            await controller.buscarEntrenamientos();
            controller.isExpanded.value = false;
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
            await controller.buscarEntrenamientos();
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

  Widget _buildSeccionResultado(ConsultaEntrenamientoController controller) {
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
    ConsultaEntrenamientoController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Entrenamientos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        AppVisibility(
          'Exportar_entrenamientos_a_excel',
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
      ],
    );
  }

  Widget _buildSeccionResultadoTabla(
    ConsultaEntrenamientoController controller,
  ) {
    final cabecera = <String>[
      'Código MCP',
      'Nombres y Apellidos',
      'Guardia',
      'Estado de entrenamiento',
      'Estado de avance',
      'Condicion',
      'Equipo',
      'Fecha de inicio',
      'Entrenador responsable',
      'Nota teorica',
      'Nota practica',
      'Horas acumuladas',
      'Horas operativas acumuladas',
    ];
    // if (controller.entrenamientoResultados.isEmpty) {
    //   return const Center(child: Text("No se encontraron resultados"));
    // }

    return Obx(
      () {
        final rowsToShow = controller.entrenamientoResultados
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

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'Autorizado':
        return Colors.green;
      case 'Entrenando':
        return Colors.yellow;
      case 'Paralizado':
        return Colors.red;
      default:
        return Colors.grey; // Color para estados desconocidos
    }
  }

  Widget _buildSeccionResultadoTablaData(
    List<EntrenamientoConsulta> data,
    ConsultaEntrenamientoController controller,
  ) {
    return SizedBox(
      height: 500,
      child: SingleChildScrollView(
        child: Column(
          children: data.map((fila) {
            final estado = fila.estadoEntrenamiento.nombre!;
            final color = _getColorForEstado(estado);

            final celdas = <Widget>[
              Text(fila.codigoMcp),
              Text(fila.nombreCompleto),
              Text(fila.guardia.nombre!),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(estado),
                ],
              ),
              Text(fila.modulo.nombre!),
              Text(fila.condicion.nombre!),
              Text(fila.equipo.nombre!),
              Text(DateFormat('dd/MM/yyyy').format(fila.fechaInicio!)),
              Text(fila.entrenador.nombre!),
              Text(fila.notaTeorica.toString()),
              Text(fila.notaPractica.toString()),
              Text(fila.horasAcumuladas.toString()),
              Text(fila.horasOperativasAcumuladas.toString()),
            ];
            return _buildFila(celdas);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFila(List<Widget> celdas) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: celdas.map((celda) {
          return Expanded(child: celda);
        }).toList(),
      ),
    );
  }

  Widget _buildSeccionResultadoTablaPaginado(
    ConsultaEntrenamientoController ctr,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () {
            final from = ctr.currentPage.value * ctr.rowsPerPage.value -
                ctr.rowsPerPage.value +
                1;
            final to = ctr.currentPage.value * ctr.rowsPerPage.value >
                    ctr.totalRecords.value
                ? ctr.totalRecords.value
                : ctr.currentPage.value * ctr.rowsPerPage.value;

            return Text(
              'Mostrando $from - $to de ${ctr.totalRecords.value} registros',
              style: const TextStyle(fontSize: 14),
            );
          },
        ),
        Obx(
          () => Row(
            children: [
              const Text('Items por página: '),
              DropdownButton<int>(
                value: ctr.rowsPerPage.value > 0 && ctr.rowsPerPage.value <= 50
                    ? ctr.rowsPerPage.value
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
                    ctr.rowsPerPage.value = value;
                    ctr.currentPage.value = 1;
                    ctr.buscarEntrenamientos(
                      pageNumber: ctr.currentPage.value,
                      pageSize: value,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: ctr.currentPage.value > 1
                    ? () {
                        ctr.currentPage.value--;
                        ctr.buscarEntrenamientos(
                          pageNumber: ctr.currentPage.value,
                          pageSize: ctr.rowsPerPage.value,
                        );
                      }
                    : null,
              ),
              Text(
                '${ctr.currentPage.value} de ${ctr.totalPages.value}',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: ctr.currentPage.value < ctr.totalPages.value
                    ? () {
                        ctr.currentPage.value++;
                        ctr.buscarEntrenamientos(
                          pageNumber: ctr.currentPage.value,
                          pageSize: ctr.rowsPerPage.value,
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
}
