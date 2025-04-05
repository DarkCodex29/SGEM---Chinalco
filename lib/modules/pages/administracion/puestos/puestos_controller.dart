import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/api/api.maestro.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/shared/models/maestro_detalle.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';

class PuestosController extends GetxController {
  PuestosController(
    this.context, {
    MaestroService? maestroService,
    MaestroDetalleService? maestroDetalleService,
  }) : _maestroDetalleService =
            maestroDetalleService ?? MaestroDetalleService();

  @override
  Future<void> onInit() async {
    await search(
      context,
    );
    super.onInit();
  }

  final BuildContext context;
  final MaestroDetalleService _maestroDetalleService;

  final result = <Detalle>[].obs;
  final rowsPerPage = 10.obs;

  Future<void> search(
    BuildContext context,
  ) async {
    final response = await _maestroDetalleService.getMaestroDetalles(
      maestroKey: 5, // 5: Familia de Puestos
    );

    if (response.success) {
      result.assignAll(response.data!);
    } else {
      MensajeValidacionWidget(
        errores: [response.message ?? 'Error al cargar los maestros'],
      ).show(context);
    }
  }
}
