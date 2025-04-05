import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.maestro.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class MaestroController extends GetxController {
  MaestroController({
    MaestroService? maestroService,
    MaestroDetalleService? maestroDetalleService,
  })  : _maestroService = maestroService ?? MaestroService(),
        _maestroDetalleService =
            maestroDetalleService ?? MaestroDetalleService();

  @override
  Future<void> onInit() async {
    await search();
    super.onInit();
  }

  final Logger _logger = Logger('MaestroController');

  final MaestroService _maestroService;
  final MaestroDetalleService _maestroDetalleService;

  final maestroController = DropdownController();
  final estadoController = DropdownController();

  final maestros = <OptionValue>[].obs;

  final TextEditingController valorController = TextEditingController();
  static const _allMaestro = OptionValue(key: 0, nombre: 'Todos');

  void clearFilter() {
    debugPrint('Clear filter');
    valorController.clear();
    maestroController.clear();
    estadoController.clear();

    search();
  }

  final result = <Detalle>[].obs;
  final rowsPerPage = 10.obs;

  Future<List<OptionValue>?> getMaestros() async {
    final response = await _maestroService.getMaestros();
    if (!response.success) {
      _logger.severe(response.message ?? 'Error al cargar los maestros');
    }

    if (response.data != null) {
      maestros.value = [_allMaestro, ...response.data!];
    }

    return response.data;
  }

  Future<void> search() async {
    final maestroKey = maestroController.value;
    final estado = estadoController.value;
    final valor = valorController.text;

    final response = await _maestroDetalleService.getMaestroDetalles(
      maestroKey: maestroKey == -1 ? null : maestroKey,
      value: valor.isEmpty ? null : valor,
      status: estado == -1 ? null : estado,
    );

    if (response.success) {
      result.assignAll(response.data!);
    } else {
      _logger.severe(response.message ?? 'Error al cargar los maestros');
    }
  }
}
