import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/api/api.modulo.maestro.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/dialogs/success_dialog.dart';
import 'package:sgem/shared/modules/modulo_model.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class ModuloEditController extends GetxController {
  ModuloEditController(
    this.modulo, {
    ModuloMaestroService? moduloService,
  }) : _moduloService = moduloService ?? ModuloMaestroService();

  @override
  Future<void> onInit() async {
    initializeDropdown();
    super.onInit();
  }

  final ModuloMaestroService _moduloService;
  final Modulo modulo;

  final GenericDropdownController dropdownController =
      Get.find<GenericDropdownController>();

  static const _statusOptions = [
    OptionValue(key: 1, nombre: 'Activo'),
    OptionValue(key: 0, nombre: 'Inactivo'),
  ];

  void initializeDropdown() {
    dropdownController
      ..loadOptions(
        'estado_modulos',
        () async => _statusOptions,
      )
      ..selectValue(
        'estado_modulos',
        modulo.status ? _statusOptions[0] : _statusOptions[1],
      );

    hourController.text = modulo.hours.toString();
    minGradeController.text = modulo.minGrade.toString();
    maxGradeController.text = modulo.maxGrade.toString();
  }

  final TextEditingController hourController = TextEditingController();
  final TextEditingController minGradeController = TextEditingController();
  final TextEditingController maxGradeController = TextEditingController();
  void clearFilter() {
    hourController.clear();
    minGradeController.clear();
    maxGradeController.clear();
    dropdownController.resetSelection('estado_modulos');
  }

  bool _validate(
    BuildContext context, {
    required String hours,
    required String minGrade,
    required String maxGrade,
    required OptionValue? status,
  }) {
    final errors = <String>[];
    if (hours.isEmpty) {
      errors.add('El campo Horas de Cumplimiento es obligatorio');
    } else if (int.tryParse(hours) == null) {
      errors.add('El campo Horas de Cumplimiento is inválido');
    }

    if (minGrade.isEmpty) {
      errors.add('El campo Nota Mínima Aprobatoria es obligatorio');
    } else if (int.tryParse(minGrade) == null) {
      errors.add('El campo Nota Mínima Aprobatoria es inválido');
    }

    if (maxGrade.isNotEmpty && int.tryParse(maxGrade) == null) {
      errors.add('El campo Nota Máxima es inválido');
    }

    if (status == null) {
      errors.add('El campo Estado es obligatorio');
    }

    if (errors.isNotEmpty) {
      context.errorSnackbar(errors.join('\n'));
      return false;
    }

    return true;
  }

  Future<void> updateModulo(
    BuildContext context,
  ) async {
    final hours = hourController.text;
    final minGrade = minGradeController.text;
    final maxGrade = maxGradeController.text;
    final status = dropdownController.getSelectedValue('estado_modulos');

    if (!_validate(
      context,
      hours: hours,
      minGrade: minGrade,
      maxGrade: maxGrade,
      status: status,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final response = await _moduloService.updateModuloMaestro(
      modulo.copyWith(
        hours: int.parse(hours),
        minGrade: int.parse(minGrade),
        maxGrade: maxGrade.isNotEmpty ? int.parse(maxGrade) : null,
        status: status!.key == 1,
      ),
    );

    if (response.success) {
      context.pop(true);
      await const SuccessDialog().show(context);
    } else {
      context.snackbar(
        'Error',
        response.message ?? 'Error al guardar el registro',
      );
    }
  }
}
