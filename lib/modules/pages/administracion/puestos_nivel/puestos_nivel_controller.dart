import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/Repository/MainRespository.dart';
import 'package:sgem/config/api/api.maestro.dart';
import 'package:sgem/config/api/api_puestos_nivel.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/dialogs/success_dialog.dart';
import 'package:sgem/shared/models/puesto.dart';
import 'package:sgem/shared/models/puestos_nivel.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class PuestosNivelController extends GetxController {
  PuestosNivelController({
    MaestroService? maestroService,
    PuestosNivelService? puestosService,
  }) : _puestosService = puestosService ?? PuestosNivelService();

  @override
  Future<void> onInit() async {
    await search();
    super.onInit();
  }

  @override
  void onClose() {
    estadoController.dispose();
    super.onClose();
  }

  final DropdownController estadoController = DropdownController();
  late Puesto puesto = Puesto.fromJson({});
  late MaestroDetalle nivel = MaestroDetalle.fromJson({});

  final PuestosNivelService _puestosService;

  final result = <PuestosNivelService>[].obs;
  final rowsPerPage = 100.obs;
  RxList<PuestosNivel> puestosNivelResultados = <PuestosNivel>[].obs;
  RxList<Puesto> puestosResult = <Puesto>[].obs;
  RxList<MaestroDetalle> nivelResultados = <MaestroDetalle>[].obs;

  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  final DropdownController nivelesDC = DropdownController();

  late int key = 0;
  late String nombrePuesto = '';
  late String nombreNivel = '';
  late int keyPuesto = 0;
  late int keyNivel = 0;

  Future<void> search([BuildContext? context = null]) async {
    // final response = await _puestosService.getMaestroDetalles(
    //   maestroKey: 5, // 5: Familia de Puestos
    // );

    final response = await _puestosService.searchPuestosNivel(
      isPaginate: false,
    );

    if (response.success && response.data != null) {
      var result = response.data as Map<String, dynamic>;
      log('Respuesta recibida correctamente $result');

      var items = result['Items'] as List<PuestosNivel>;
      log('Items obtenidos: $items');

      puestosNivelResultados.assignAll(items);
    } else {
      if (context != null) {
        MensajeValidacionWidget(
          errores: [response.message ?? 'Error al cargar los maestros'],
        ).show(context!);
      }
    }
  }

  Future<void> searchPuesto(BuildContext context, String puesto) async {
    // final response = await _puestosService.getMaestroDetalles(
    //   maestroKey: 5, // 5: Familia de Puestos
    // );
    try {
      if (puesto.length < 4) {
        return;
      }
      _debouncer.run(
        () async {
          final response = await _puestosService.searchPuestosApi(
            query: puesto,
          );
          if (response.success) {
            var result = response.data as Map<String, dynamic>;
            log('Respuesta recibida correctamente $result');

            var items = result['Items'] as List<Puesto>;
            log('Items obtenidos: $items');

            puestosResult.assignAll(items);
          } else {
            MensajeValidacionWidget(
              errores: [response.message ?? 'Error al cargar los puestos'],
            ).show(context);
          }
        },
      );
    } catch (e) {
      log('Error al cargar: $e');
    }
  }

  Future<void> searchNiveles(BuildContext context, String nivel) async {
    // final response = await _puestosService.getMaestroDetalles(
    //   maestroKey: 5, // 5: Familia de Puestos
    // );
// no puede ser un autocomplete ///
    try {
      if (nivel.length < 4) {
        return;
      }
      _debouncer.run(
        () async {
          MainRepository repository = MainRepository();
          final response = await repository.listarMaestroDetallePorMaestro(15);
          // final response = await _puestosService.searchNivelApi(
          //   query: nivel,
          // );

          if (response != null) {
            log('Items obtenidos: $response');

            if (response.length > 0) {
              nivelResultados.assignAll(response);
            } else {
              nivelResultados.clear();
            }
          } else {
            MensajeValidacionWidget(
              errores: [response?.first.value ?? 'Error al cargar los niveles'],
            ).show(context);
          }
        },
      );
    } catch (e) {
      log('Error al cargar: $e');
    }
  }

  Future<void> savePuestosNivel(
    BuildContext context,
  ) async {
    final estado = estadoController.selectedOption;

    if (!_validate(
      context,
      puesto: puesto.nombre.toString(),
      nivel: '${nivelesDC.selectedOption?.nombre}',
      estado: estado,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final newPuesto = PuestosNivel(
      activo: switch (estado!.key!) {
        1 => 'S',
        0 => 'N',
        _ => throw Exception('Estado no válido'),
      },
      usuarioModifica: 'ldolorier',
      fechaRegistro: DateTime.now(),
      nivel: OptionValue(
          key: int.parse(nivelesDC.selectedOption!.key!.toString()),
          nombre: nivelesDC.selectedOption!.nombre!),
      puesto: OptionValue(key: puesto.key, nombre: puesto.nombre),
      registro: '',
    );

    final response = await _puestosService.savePuestoNivel(newPuesto);

    if (response.success) {
      context.pop(true);
      await const SuccessDialog().show(context);
    } else {
      MensajeValidacionWidget(
        errores: [response.message ?? 'Error al actualizar el registro'],
      ).show(context);
    }
  }

  Future<void> updatePuestosNivel(
    BuildContext context,
  ) async {
    final estado = estadoController.selectedOption;

    if (!_validate(
      context,
      puesto: nombrePuesto,
      nivel: nombreNivel,
      estado: estado,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final newPuesto = PuestosNivel(
      activo: switch (estado!.key!) {
        1 => 'S',
        0 => 'N',
        _ => throw Exception('Estado no válido'),
      },
      key: key, //detalle!.key,
      usuarioModifica: 'ldolorier',
      fechaRegistro: DateTime.now(),
      nivel: OptionValue(key: keyNivel, nombre: nombreNivel),
      puesto: OptionValue(key: keyPuesto, nombre: nombrePuesto),
      registro: '',
    );

    final response = await _puestosService.updatePuestoNivel(newPuesto);

    if (response.success) {
      context.pop(true);
      await const SuccessDialog().show(context);
    } else {
      MensajeValidacionWidget(
        errores: [response.message ?? 'Error al actualizar el registro'],
      ).show(context);
    }
  }

  bool _validate(
    BuildContext context, {
    required String puesto,
    required String nivel,
    required OptionValue? estado,
  }) {
    final errors = <String>[];
    if (puesto.isEmpty) {
      errors.add('debe seleccionar un puesto.');
    }
    if (puesto.length > 250) {
      errors.add('El campo puesto no puede tener más de 250 caracteres.');
    }
    if (nivel.isEmpty || nivel == 'null') {
      errors.add('debe seleccionar un nivel.');
    }
    if (nivel.length > 200) {
      errors.add('El campo nivel no puede tener más de 200 caracteres.');
    }

    if (estado == null) {
      errors.add('El campo estado es obligatorio.');
    }

    if (errors.isNotEmpty) {
      if (context != null) {
        MensajeValidacionWidget(
          errores: errors,
        ).show(context!);
      }
      return false;
    }

    return true;
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
