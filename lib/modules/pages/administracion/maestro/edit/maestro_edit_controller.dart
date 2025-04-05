import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api.maestro.dart';
import 'package:sgem/config/api/api.maestro.detail.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/dialogs/success_dialog.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/modules/maestro.dart';
import 'package:sgem/shared/modules/maestro.detail.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/dropdown.dart';

class MaestroEditController extends GetxController {
  MaestroEditController(
    this.context,
    this.detalle, {
    MaestroService? maestroService,
    MaestroDetalleService? maestroDetalleService,
  })  : _maestroService = maestroService ?? MaestroService(),
        _maestroDetalleService =
            maestroDetalleService ?? MaestroDetalleService();

  @override
  Future<void> onInit() async {
    _logger.info('Inicializando controlador de edición de maestro');
    await initializeDropdown(
      context,
    );
    maestroController.addListener(() => _onMaestroChange(context));
    super.onInit();
  }

  final BuildContext context;
  final MaestroService _maestroService;
  final MaestroDetalleService _maestroDetalleService;
  final Detalle? detalle;

  static final _logger = Logger('MaestroEditController');

  Future<void> initializeDropdown(
    BuildContext context,
  ) async {
    valorController.text = detalle?.nombre ?? '';
    descripcionController.text = detalle?.descripcion ?? '';

    if (detalle == null) return;

    estadoController.value = detalle!.activo ? 1 : 0;

    maestroController
      ..options = Get.find<MaestraController>().maestros
      ..value = detalle!.maestro.key;
    relacionController.value = detalle!.detalleRelacion?.key;
    await _onMaestroChange(context, clear: false);

    if (detalle!.maestro.key == 5) {
      codigoMinestarController.text = detalle!.valorString ?? '';
      codigoEquipoController.text = detalle!.valorStringAdicional ?? '';
    }
  }

  @override
  void onClose() {
    valorController.dispose();
    descripcionController.dispose();
    codigoMinestarController.dispose();
    codigoEquipoController.dispose();
    maestroController
      ..removeListener(() => _onMaestroChange(context))
      ..dispose();
    estadoController.dispose();
    relacionController.dispose();
    super.onClose();
  }

  final TextEditingController valorController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController codigoMinestarController =
      TextEditingController();
  final TextEditingController codigoEquipoController = TextEditingController();

  final DropdownController maestroController = DropdownController();
  final DropdownController estadoController = DropdownController();
  final DropdownController relacionController = DropdownController();

  final loading = false.obs;
  final detailsRelated = <Detalle>[].obs;

  void clearFilter() {
    valorController.clear();
    descripcionController.clear();
    codigoMinestarController.clear();
    codigoEquipoController.clear();
    maestroController.clear();
    estadoController.clear();
    relacionController.clear();
  }

  Future<void> _onMaestroChange(BuildContext context,
      {bool clear = true}) async {
    try {
      _logger.info('Cambiando maestro');
      if (clear) {
        relacionController.clear();
        codigoMinestarController.clear();
        codigoEquipoController.clear();
      }
      _logger.info(maestroController.selectedOption);

      final maestro = maestroController.selectedOption as Maestro?;
      if (maestro == null) return;

      final relacion = maestro.maestroRelacion?.key;
      _logger.info(relacion);
      if (relacion == null) {
        detailsRelated.clear();
        return;
      }

      loading.value = true;

      _logger.info('Obteniendo detalles por maestro $relacion');
      final response =
          await _maestroDetalleService.getDetailsByMaestro(relacion);

      if (!response.success) {
        return MensajeValidacionWidget(
          errores: [response.message ?? 'Error al obtener los detalles'],
        ).show(context);
      }

      detailsRelated.assignAll(response.data!);
    } catch (e, stackTrace) {
      _logger.severe(e, stackTrace);
      return MensajeValidacionWidget.single('Error al obtener los detalles')
          .show(context);
    } finally {
      loading.value = false;
    }
  }

  bool _validate({
    required String valor,
    required OptionValue? maestro,
    required String descripcion,
    required OptionValue? estado,
    required OptionValue? relacion,
    String codigoMinestar = '',
    String codigoEquipo = '',
  }) {
    final errors = <String>[];
    if (valor.isEmpty) {
      errors.add('El campo valor es obligatorio');
    } else if (valor.length > 50) {
      errors.add('El campo valor no puede tener más de 50 caracteres');
    }

    if (maestro == null) {
      errors.add('El campo maestro es obligatorio');
    } else {
      maestro as Maestro;
      if (maestro.maestroRelacion != null) {
        if (relacion == null) {
          errors.add(
            'El campo ${maestro.maestroRelacion!.nombre ?? 'relación'} '
            'es obligatorio',
          );
        }
      }

      if (maestro.key == 5) {
        if (codigoMinestar.isEmpty) {
          errors.add('El campo código minestar es obligatorio');
        }

        if (codigoEquipo.isEmpty) {
          errors.add('El campo código familia de equipo es obligatorio');
        }
      }
    }

    if (descripcion.length > 200) {
      errors.add('El campo descripción no puede tener más de 200 caracteres');
    }

    if (estado == null) {
      errors.add('El campo estado es obligatorio');
    }

    if (errors.isNotEmpty) {
      MensajeValidacionWidget(
        errores: errors,
      ).show(context);
      return false;
    }

    return true;
  }

  Future<void> saveDetalle(
    BuildContext context,
  ) async {
    final valor = valorController.text;
    final maestro = maestroController.selectedOption;
    final descripcion = descripcionController.text;
    final estado = estadoController.selectedOption;
    final relacion = relacionController.selectedOption;
    final codigoMinestar = codigoMinestarController.text;
    final codigoEquipo = codigoEquipoController.text;

    _logger.info(maestro);

    if (!_validate(
      valor: valor,
      maestro: maestro,
      descripcion: descripcion,
      estado: estado,
      relacion: relacion,
      codigoMinestar: codigoMinestar,
      codigoEquipo: codigoEquipo,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    try {
      final response = await _maestroDetalleService.registrateMaestroDetalle(
        Detalle(
          nombre: valor,
          activo: switch (estado!.key!) {
            1 => true,
            0 => false,
            _ => throw Exception('Estado no válido'),
          },
          detalleRelacion: relacion,
          valorString: codigoMinestar.isEmpty ? null : codigoMinestar,
          valorStringAdicional: codigoEquipo.isEmpty ? null : codigoEquipo,
          maestro: OptionValue(
            key: maestro!.key,
            nombre: maestro.nombre,
          ),
          descripcion: descripcion.isEmpty ? null : descripcion,
        ),
      );

      if (response.success) {
        context.pop();
        await const SuccessDialog().show(context);
      } else {
        return MensajeValidacionWidget.single(
          response.message ?? 'Error al guardar el registro',
        ).show(context);
      }
    } catch (e, stackTrace) {
      _logger.severe(e, stackTrace);
      return MensajeValidacionWidget.single(
        'Error al guardar el registro',
      ).show(context);
    }
  }

  Future<void> updateDetalle(
    BuildContext context,
  ) async {
    final valor = valorController.text;
    final maestro = maestroController.selectedOption;
    final descripcion = descripcionController.text;
    final estado = estadoController.selectedOption;
    final relacion = relacionController.selectedOption;
    final codigoMinestar = codigoMinestarController.text;
    final codigoEquipo = codigoEquipoController.text;

    if (!_validate(
      valor: valor,
      maestro: maestro,
      descripcion: descripcion,
      estado: estado,
      relacion: relacion,
      codigoMinestar: codigoMinestar,
      codigoEquipo: codigoEquipo,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    try {
      final newDetalle = Detalle(
        nombre: valor,
        activo: switch (estado!.key!) {
          1 => true,
          0 => false,
          _ => throw Exception('Estado no válido'),
        },
        detalleRelacion: relacion,
        valorString: codigoMinestar.isEmpty ? null : codigoMinestar,
        valorStringAdicional: codigoEquipo.isEmpty ? null : codigoEquipo,
        maestro: OptionValue(
          key: maestro!.key,
          nombre: maestro.nombre,
        ),
        descripcion: descripcion.isEmpty ? null : descripcion,
        key: detalle!.key,
      );

      final response =
          await _maestroDetalleService.updateMaestroDetalle(newDetalle);

      if (!context.mounted) return;

      if (response.success) {
        context.pop(true);
        await const SuccessDialog().show(context);
      } else {
        _logger.warning(response.message);
        return MensajeValidacionWidget.single(
          response.message ?? 'Error al actualizar el registro',
        ).show(context);
      }
    } catch (e, stackTrace) {
      _logger.severe(e, stackTrace);
      if (!context.mounted) return;
      return MensajeValidacionWidget.single('Error al actualizar el registro')
          .show(context);
    }
  }
}
