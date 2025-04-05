part of 'rol_dialog.dart';

class RolController extends GetxController {
  RolController({
    this.rol,
    RolPermisoService? api,
  }) : _api = api ?? RolPermisoService();

  final RolPermisoService _api;
  final Rol? rol;

  @override
  Future<void> onInit() async {
    super.onInit();
    name.text = rol?.name ?? '';
    active.value = rol?.actived;
  }

  final TextEditingController name = TextEditingController();
  final active = Rxn<bool>();

  bool _validate(
    context, {
    required String? nameValue,
    required bool? activeValue,
  }) {
    final errors = <String>[];

    if (nameValue?.isEmpty ?? true) {
      errors.add('Debe ingresar el nombre del rol');
    }

    if (activeValue == null) {
      errors.add('Debe seleccionar si el rol está activo o no');
    }

    if (errors.isNotEmpty) {
      MensajeValidacionWidget(errores: errors).show(context);
      return false;
    }
    return true;
  }

  Future<void> updateRol(
    BuildContext context,
  ) async {
    final activeValue = active.value;
    final nameValue = name.text.trim();

    if (!_validate(
      context,
      nameValue: nameValue,
      activeValue: activeValue,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    if (rol == null) {
      context.errorSnackbar('Error al actualizar rol');
      return;
    }

    final rolUpdated = Rol(
      key: rol!.key,
      name: nameValue,
      actived: activeValue!,
    );

    final response = await _api.updateRol(rolUpdated);

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [response.message ?? 'Error al actualizar rol'],
      ).show(context);
    }

    await const SuccessDialog().show(context);
    context.pop(true);
  }

  Future<void> saveRol(
    BuildContext context,
  ) async {
    final activeValue = active.value;
    final nameValue = name.text.trim();

    if (!_validate(
      context,
      nameValue: nameValue,
      activeValue: activeValue,
    )) return;

    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final rol = Rol(
      name: nameValue,
      actived: activeValue!,
    );

    final response = await _api.registrateRol(rol);

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [response.message ?? 'Error al guardar rol'],
      ).show(context);
    }

    await const SuccessDialog().show(context);
    context.pop(true);
  }
}
