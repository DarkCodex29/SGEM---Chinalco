import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/modules/pages/administracion/rolesPermisos/roles_permisos.dart';
import 'package:sgem/shared/models/models.dart';
import 'package:sgem/shared/utils/Extensions/format_extension.dart';
import 'package:sgem/shared/widgets/active_box.dart';
import 'package:sgem/shared/widgets/table/data.table.dart';

class RoleDataTable extends StatelessWidget {
  const RoleDataTable({
    required this.roles,
    super.key,
  });

  final RxList<Rol> roles;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return DataTable2(
        columns: const [
          // 'Código',
          'Rol',
          'Usuario registro',
          'Fecha de registro',
          'Usuario modificación',
          'Fecha de modificación',
          'Estado',
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
        rows: roles
            .map(
              (rol) => DataRow(
                cells: [
                  // DataCell(Text(rol.key.format)),
                  DataCell(Center(child: Text(rol.name))),
                  DataCell(Center(child: Text(rol.userRegister))),
                  DataCell(
                    Center(child: Text(rol.dateRegister.formatExtended)),
                  ),
                  DataCell(Center(child: Text(rol.userUpdate))),
                  DataCell(
                    Center(child: Text(rol.dateUpdate.formatExtended)),
                  ),
                  DataCell(Center(child: ActiveBox(isActive: rol.actived))),
                  DataCell(
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Get.find<RolPermisoController>()
                            .onRolEdit(context, rol),
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      );
    });
  }
}
