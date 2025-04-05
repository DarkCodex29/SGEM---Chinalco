import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/modules/pages/administracion/rolesPermisos/roles_permisos.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';

class PermisosTabWidget extends StatelessWidget {
  const PermisosTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctr = Get.put(RolPermisoController(context));
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.width * 0.0),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => ctr.onPermisoEdit(context),
              icon: const Icon(
                Icons.add,
                size: 18,
                color: AppTheme.primaryBackground,
              ),
              label: const Text(
                'Nuevo permiso',
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
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PermisoDataTable(permisos: ctr.permisos),
          ),
        ],
      ),
    );
  }
}

class PermisoDataTable extends StatelessWidget {
  const PermisoDataTable({
    required this.permisos,
    super.key,
  });

  final RxList<Permiso> permisos;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return DataTable2(
          columns: const [
            'Módulo',
            'Código',
            'Estado',
            'Usuario registro',
            'Fecha registro',
            'Usuario modificación',
            'Fecha modificación',
            'Acciones',
          ].map((e) => DataColumn2(label: Center(child: Text(e)))).toList(),
          dataRowColor: MaterialStateProperty.all(Colors.white),
          headingTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          headingRowDecoration: const BoxDecoration(
            color: Color.fromARGB(20, 0, 0, 0),
          ),
          dataRowHeight: 60,
          rows: permisos
              .map(
                (permiso) => DataRow(
                  cells: [
                    // DataCell(Text(permiso.key.format)),
                    DataCell(
                      Center(child: Text(permiso.module.nombre ?? 'N/A')),
                    ),
                    DataCell(Center(child: Text(permiso.code))),
                    DataCell(
                      Center(child: ActiveBox(isActive: permiso.actived)),
                    ),
                    DataCell(Center(child: Text(permiso.userRegister))),
                    DataCell(
                      Center(
                        child: Text(permiso.dateRegister.formatExtended),
                      ),
                    ),
                    DataCell(Center(child: Text(permiso.userUpdate))),
                    DataCell(
                      Center(
                        child: Text(permiso.dateUpdate.formatExtended),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => Get.find<RolPermisoController>()
                              .onPermisoEdit(context, permiso),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}
