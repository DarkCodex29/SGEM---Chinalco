import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/rolesPermisos/roles_permisos_controller.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/widgets/dropDown/simple_app_dropdown.dart';

class RolesPorPermisoTabWidget extends StatelessWidget {
  const RolesPorPermisoTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrPermissions = Get.find<RolPermisoController>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Obx(
              () {
                return SimpleAppDropdown(
                  options: ctrPermissions.roles
                      .where((r) => r.actived)
                      .map((e) => (e.key, e.name))
                      .toList(),
                  label: 'Rol',
                  onChanged: (value) {
                    final rol = value == null
                        ? null
                        : ctrPermissions.roles
                            .firstWhere((e) => e.key == value);
                    ctrPermissions.changeRolFiltro(rol);
                  },
                  isRequired: true,
                  // dropdownKey: 'maestro_2',
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final ctr = Get.find<MaestraController>();
              final modulos = ctr.modulosPermisos.toOptionValue();
              final rolPermiso = ctrPermissions.permisosFiltrados;
              final rol = ctrPermissions.rolFiltro;

              // if (ctrPermissions.loading) {
              //   return const Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }
              if (ctr.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (rolPermiso.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final modulo in modulos)
                            Builder(
                              builder: (context) {
                                final rolPermisos = rolPermiso
                                    .mapIndexed(
                                      (index, element) =>
                                          (index, element.$1, element.$2),
                                    )
                                    .where(
                                      (e) => e.$2.module.key == modulo.key,
                                    );

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      modulo.nombre!,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(
                                        color: AppTheme.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    for (final (index, permiso, check)
                                        in rolPermisos)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              tristate: true,
                                              value: rol == null ? null : check,
                                              onChanged: rol == null
                                                  ? null
                                                  : (_) => ctrPermissions
                                                      .changeRolPermiso(index),
                                              checkColor: AppTheme.accent1,
                                            ),
                                            const SizedBox(width: 20),
                                            Text(
                                              permiso.code,
                                              style: const TextStyle(
                                                color: AppTheme.primaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (rolPermiso.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => ctrPermissions.saveRolPermisos(context),
                      icon: const Icon(
                        Icons.save,
                        size: 18,
                        color: AppTheme.primaryBackground,
                      ),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryBackground,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
