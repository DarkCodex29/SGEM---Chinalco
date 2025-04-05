import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/api/api_usuario.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/models/usuario.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';
import 'package:sgem/shared/widgets/dropDown/maestra_app_dropdown.dart';

class UsuarioController extends GetxController {
  UsuarioController({
    UsuarioService? personalService,
    Usuario? user,
  })  : _usuarioService = personalService ?? UsuarioService(),
        user = Rxn<Usuario>(user);

  final Rxn<Usuario> user;

  final UsuarioService _usuarioService;

  final TextEditingController userCode = TextEditingController();
  final TextEditingController name = TextEditingController();
  final estado = RxnBool();
  final DropdownController rol = DropdownController();

  @override
  Future<void> onInit() async {
    super.onInit();

    final user = this.user.value;
    if (user != null) {
      Logger('UsuarioController').info('Usuario: $user');
      userCode.text = user.personal.nombre.toString();
      name.text = user.personal.nombre!;
      estado.value = user.state;
      rol.value = user.rol.key;
    }
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    userCode.dispose();
  }

  void clear() {
    userCode.clear();
    name.clear();
    rol.clear();
    estado.value = null;
  }

  bool _validate(
    BuildContext context,
    int? personal,
    int? rol,
    bool? estado,
  ) {
    final errors = <String>[];
    if (personal == null) {
      errors.add('Seleccione un personal');
    }
    if (rol == null) {
      errors.add('Seleccione un rol');
    }
    if (estado == null) {
      errors.add('Seleccione un estado');
    }

    Logger('UsuarioController').info('Errores: $errors');
    if (errors.isNotEmpty) {
      MensajeValidacionWidget(errores: errors).show(context);
      return false;
    }

    return true;
  }

  Future<void> searchUser(
    BuildContext context,
  ) async {
    final personal = userCode.text;

    if (personal.isEmpty) {
      MensajeValidacionWidget(
        errores: ['Ingrese el correo o nombre del usuario'],
      ).show(context);
      return;
    }

    final response = await _usuarioService.searchUsuario(query: personal);

    Logger('UsuarioController').info(response);

    if (response.success) {
      final result = response.data!;

      if (result.key < 0) {
        MensajeValidacionWidget(
          errores: ['No se encontró el personal'],
        ).show(context);
        return;
      }

      user.value = response.data!;
    } else {
      MensajeValidacionWidget(errores: [
        response.message ?? 'Error al buscar el personal',
      ]).show(context);
    }
  }

  Future<void> updateUser(
    BuildContext context,
  ) async {
    final rol = this.rol.value;
    final personal = this.user.value?.personal.key;
    final estado = this.estado.value;

    if (!_validate(context, personal, rol, estado)) return;

    final confirmation = await ConfirmDialog().show(context);
    if (!(confirmation ?? false)) return;

    final response = await _usuarioService.updateUsuario(
      user.value!.copyWith(
        rol: rol!,
        personal: personal!,
        estado: estado!,
      ),
    );

    if (response.success) {
      context.pop(true);
    } else {
      MensajeValidacionWidget(errores: [
        response.message ?? 'Error al actualizar el usuario',
      ]).show(context);
    }
  }

  Future<void> saveUser(
    BuildContext context,
  ) async {
    final rol = this.rol.value;
    final personal = this.user.value?.personal.key;
    final estado = this.estado.value;

    if (!_validate(context, personal, rol, estado)) return;

    final confirmation = await ConfirmDialog().show(context);
    if (!(confirmation ?? false)) return;

    final response = await _usuarioService.registrateUsuario(
      Usuario(
        rol: OptionValue(key: rol!),
        personal: OptionValue(key: personal!),
        state: estado!,
      ),
    );

    if (response.success) {
      context.pop(true);
    } else {
      MensajeValidacionWidget(errores: [
        response.message ?? 'Error al registrar el usuario',
      ]).show(context);
    }
  }
}
