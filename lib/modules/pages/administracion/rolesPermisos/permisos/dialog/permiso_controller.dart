part of 'permiso_dialog.dart';

class PermisoController extends GetxController {
  PermisoController({
    this.permiso,
    RolPermisoService? api,
  }) : _api = api ?? RolPermisoService();

  final RolPermisoService _api;
  final Permiso? permiso;

  @override
  Future<void> onInit() async {
    super.onInit();
    moduloController.value = permiso?.module.key;
    active.value = permiso?.actived;
    code.text = permiso?.code ?? '';
  }

  @override
  void onClose() {
    moduloController.dispose();
    code.dispose();
    super.onClose();
  }

  // final TextEditingController name = TextEditingController();
  final moduloController = DropdownController();
  final TextEditingController code = TextEditingController();
  final active = Rxn<bool>();

  bool _validate(
    BuildContext context, {
    required int? moduloValue,
    required String? codeValue,
    required bool? activeValue,
  }) {
    final errors = <String>[];

    if (moduloValue == null) {
      errors.add('Debe seleccionar un módulo');
    }

    if (codeValue == null || codeValue.isEmpty) {
      errors.add('Debe ingresar el código del permiso');
    }

    if (activeValue == null) {
      errors.add('Debe seleccionar si el permiso está activo o no');
    }

    if (errors.isNotEmpty) {
      MensajeValidacionWidget(errores: errors).show(context);
      return false;
    }
    return true;
  }

  Future<void> updatePermiso(
    BuildContext context,
  ) async {
    if (permiso == null) {
      context.errorSnackbar('Error al actualizar permiso');
      return;
    }

    final activeValue = active.value;
    final codeValue = code.text.trim();
    final moduloValue = moduloController.value;

    if (!_validate(
      context,
      moduloValue: moduloValue,
      codeValue: codeValue,
      activeValue: activeValue,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final permisoUpdated = Permiso(
      key: permiso!.key,
      code: codeValue,
      actived: activeValue!,
      module: OptionValue(key: moduloValue),
    );

    final response = await _api.updatePermiso(permisoUpdated);

    if (!context.mounted) return;

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [response.message ?? 'Error al actualizar permiso'],
      ).show(context);
    }

    await const SuccessDialog().show(context);

    if (!context.mounted) return;
    context.pop(true);
  }

  Future<void> savePermiso(
    BuildContext context,
  ) async {
    final activeValue = active.value;
    final codeValue = code.text.trim();
    final moduloValue = moduloController.value;

    if (!_validate(
      context,
      moduloValue: moduloValue,
      codeValue: codeValue,
      activeValue: activeValue,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final permiso = Permiso(
      code: code.text.trim(),
      userRegister: 'ldolorier',
      module: OptionValue(key: moduloValue),
      actived: activeValue!,
    );

    final response = await _api.registratePermiso(permiso);
    if (!context.mounted) return;

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [response.message ?? 'Error al crear permiso'],
      ).show(context);
    }

    await const SuccessDialog().show(context);

    if (!context.mounted) return;
    context.pop(true);
  }
}
