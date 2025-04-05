import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sgem/config/api/api_rol_permiso.dart';
import 'package:sgem/modules/pages/administracion/rolesPermisos/roles_permisos.dart';
import 'package:sgem/shared/dialogs/confirm_dialog.dart';
import 'package:sgem/shared/dialogs/success_dialog.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/utils/Extensions/get_snackbar.dart';
import 'package:sgem/shared/widgets/alert/widget.alert.dart';

typedef RolPermiso = (Permiso permiso, bool active);

class RolPermisoController extends GetxController {
  RolPermisoController(
    this.context, {
    RolPermisoService? api,
  }) : _api = api ?? RolPermisoService();

  final RolPermisoService _api;
  final BuildContext context;

  @override
  Future<void> onInit() async {
    super.onInit();
    unawaited(_getRoles(
      context,
    ));
    unawaited(_getPermisos(
      context,
    ));
  }

  final tabIndex = 0.obs;
  final roles = <Rol>[].obs;

  final permisos = <Permiso>[].obs;

  final _rolFiltro = Rxn<Rol>();
  Rol? get rolFiltro => _rolFiltro.value;
  final permisosFiltrados = <RolPermiso>[].obs;

  final _permisosFiltrados = <Permiso>[].obs;

  final _loading = false.obs;
  bool get loading => _loading.value;

  Future<void> _getRoles(
    BuildContext context,
  ) async {
    _loading.value = true;
    try {
      final rolesData = await _api.getRoles();

      if (!rolesData.success) {
        context.errorSnackbar(rolesData.message ?? 'Error al listar roles');
        return;
      }

      roles.value = rolesData.data!;
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _getPermisos(
    BuildContext context,
  ) async {
    _loading.value = true;
    try {
      final permisosData = await _api.getPermisos();

      if (!permisosData.success) {
        context
            .errorSnackbar(permisosData.message ?? 'Error al listar permisos');
        return;
      }

      permisos.value = permisosData.data!;

      await changeRolFiltro(rolFiltro);
    } finally {
      _loading.value = false;
    }
  }

  Future<void> changeRolFiltro(Rol? rol) async {
    _rolFiltro.value = rol;

    if (rol == null) {
      permisosFiltrados.assignAll(
        permisos.where((p) => p.actived).map((p) => (p, false)),
      );
      return;
    }

    _loading.value = true;
    final permisosData = await _api.getPermisosPorRol(rol: rol.key);
    _loading.value = false;

    if (!permisosData.success) {
      context.errorSnackbar(permisosData.message ?? 'Error al listar permisos');
      return;
    }

    _permisosFiltrados.value = permisosData.data!;
    final permisosActivos = permisosData.data!.map((p) => p.key);

    permisosFiltrados.value = permisos.where((p) => p.actived).map((permiso) {
      final active = permisosActivos.contains(permiso.key);
      return (permiso, active);
    }).toList();
  }

  void changeRolPermiso(int index) {
    final permiso = permisosFiltrados[index];
    permisosFiltrados[index] = (permiso.$1, !permiso.$2);
  }

  Future<void> onRolEdit(BuildContext context, [Rol? rol]) async {
    if ((await RolDialog(rol: rol).show(context)) ?? false) {
      await _getRoles(
        context,
      );
    }
  }

  Future<void> onPermisoEdit(BuildContext context, [Permiso? permiso]) async {
    if ((await PermisoDialog(permiso: permiso).show(context)) ?? false) {
      await _getPermisos(
        context,
      );
    }
  }

  /// Send the changes difference to the server
  Future<void> saveRolPermisos(
    BuildContext context,
  ) async {
    final confirm = await const ConfirmDialog().show(context);

    if (!(confirm ?? false)) return;

    final rol = rolFiltro;
    if (rol == null) {
      context.errorSnackbar('Debe seleccionar un rol');
      return;
    }

    final oldActivePermisos = _permisosFiltrados.map((e) => e.key).toSet();
    final newActivePermisos =
        permisosFiltrados.where((e) => e.$2).map((e) => e.$1.key).toSet();

    final toAdd = newActivePermisos.difference(oldActivePermisos);
    final toRemove = oldActivePermisos.difference(newActivePermisos);

    final response = await _api.updateRolPermisos(
      rol: rol.key,
      toAdd: toAdd.toList(),
      toRemove: toRemove.toList(),
    );

    if (!response.success) {
      return MensajeValidacionWidget(
        errores: [response.message ?? 'Error al actualizar permisos'],
      ).show(context);
    }

    await const SuccessDialog().show(context);
    context.pop(true);

    await changeRolFiltro(rol);
  }
}
